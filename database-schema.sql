-- ThesisFlow Database Schema for Supabase
-- This schema sets up the complete database structure for the Research Operating System

-- Enable UUID extension for primary keys
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    institution TEXT,
    research_area TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Main PhD topics table
CREATE TABLE IF NOT EXISTS public.topics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Recursive concepts table for hierarchical topic breakdown
CREATE TABLE IF NOT EXISTS public.concepts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    topic_id UUID NOT NULL REFERENCES public.topics(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES public.concepts(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    level INTEGER NOT NULL CHECK (level > 0),
    path TEXT NOT NULL, -- Materialized path for efficient querying
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT valid_hierarchy CHECK (
        (parent_id IS NULL AND level = 1) OR 
        (parent_id IS NOT NULL AND level > 1)
    )
);

-- Papers table for storing research paper metadata
CREATE TABLE IF NOT EXISTS public.papers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    arxiv_id TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    authors TEXT[],
    abstract TEXT,
    pdf_url TEXT,
    published_date DATE,
    citation_count INTEGER DEFAULT 0,
    reproducibility_score BOOLEAN DEFAULT FALSE,
    code_urls TEXT[],
    dataset_urls TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Junction table for concept-paper relationships
CREATE TABLE IF NOT EXISTS public.concept_papers (
    concept_id UUID NOT NULL REFERENCES public.concepts(id) ON DELETE CASCADE,
    paper_id UUID NOT NULL REFERENCES public.papers(id) ON DELETE CASCADE,
    relevance_score FLOAT DEFAULT 1.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (concept_id, paper_id)
);

-- User interactions with papers (reading progress, annotations)
CREATE TABLE IF NOT EXISTS public.user_interactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    paper_id UUID NOT NULL REFERENCES public.papers(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('to_read', 'reading', 'done', 'saved')),
    notes TEXT,
    tags TEXT[],
    read_progress INTEGER DEFAULT 0 CHECK (read_progress >= 0 AND read_progress <= 100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, paper_id)
);

-- User's personal library/saved papers
CREATE TABLE IF NOT EXISTS public.user_library (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    paper_id UUID NOT NULL REFERENCES public.papers(id) ON DELETE CASCADE,
    folder TEXT DEFAULT 'General',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, paper_id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_concepts_topic_id ON public.concepts(topic_id);
CREATE INDEX IF NOT EXISTS idx_concepts_parent_id ON public.concepts(parent_id);
CREATE INDEX IF NOT EXISTS idx_concepts_path ON public.concepts(path);
CREATE INDEX IF NOT EXISTS idx_papers_arxiv_id ON public.papers(arxiv_id);
CREATE INDEX IF NOT EXISTS idx_papers_published_date ON public.papers(published_date DESC);
CREATE INDEX IF NOT EXISTS idx_concept_papers_concept_id ON public.concept_papers(concept_id);
CREATE INDEX IF NOT EXISTS idx_concept_papers_paper_id ON public.concept_papers(paper_id);
CREATE INDEX IF NOT EXISTS idx_user_interactions_user_id ON public.user_interactions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_interactions_paper_id ON public.user_interactions(paper_id);
CREATE INDEX IF NOT EXISTS idx_user_library_user_id ON public.user_library(user_id);

-- Create updated_at triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_topics_updated_at BEFORE UPDATE ON public.topics 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_concepts_updated_at BEFORE UPDATE ON public.concepts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_papers_updated_at BEFORE UPDATE ON public.papers 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_interactions_updated_at BEFORE UPDATE ON public.user_interactions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.concepts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.papers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.concept_papers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_library ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
-- Users can only see their own data
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Topics are private to the user who created them
CREATE POLICY "Users can view own topics" ON public.topics
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own topics" ON public.topics
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own topics" ON public.topics
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own topics" ON public.topics
    FOR DELETE USING (auth.uid() = user_id);

-- Concepts inherit privacy from their parent topic
CREATE POLICY "Users can view concepts from own topics" ON public.concepts
    FOR SELECT USING (
        topic_id IN (
            SELECT id FROM public.topics WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create concepts in own topics" ON public.concepts
    FOR INSERT WITH CHECK (
        topic_id IN (
            SELECT id FROM public.topics WHERE user_id = auth.uid()
        )
    );

-- Papers are public, but interactions are private
CREATE POLICY "Papers are publicly viewable" ON public.papers
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert papers" ON public.papers
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- User interactions are private
CREATE POLICY "Users can view own interactions" ON public.user_interactions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own interactions" ON public.user_interactions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own interactions" ON public.user_interactions
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own interactions" ON public.user_interactions
    FOR DELETE USING (auth.uid() = user_id);

-- User library is private
CREATE POLICY "Users can view own library" ON public.user_library
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can add to own library" ON public.user_library
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can remove from own library" ON public.user_library
    FOR DELETE USING (auth.uid() = user_id);