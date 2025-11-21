# ThesisFlow - Research Operating System for PhD Scholars

A comprehensive SaaS platform that helps PhD scholars break down complex research topics into atomic sub-concepts, discover relevant papers, and track their research progress.

## Features

### 🧠 Topic Atomization
- AI-powered breakdown of broad PhD topics into hierarchical concept trees
- Automatic generation of research sub-topics using LLMs
- Nested concept visualization with interactive tree structure

### 📚 Paper Discovery
- Integration with arXiv API for real-time paper fetching
- Semantic search across paper titles, abstracts, and authors
- Automatic filtering for recent papers (last 3 years)
- Reproducibility scoring based on code/data availability

### 🔬 Research Management
- Progress tracking with status indicators (to_read, reading, done, saved)
- Personal library for saved papers
- Annotation and note-taking capabilities
- Citation count tracking and impact metrics

### 🎨 Clean Academic Interface
- Notion-inspired clean, distraction-free design
- Responsive layout with sidebar navigation
- Dark/light mode support
- Professional typography and spacing

## Tech Stack

- **Framework**: Next.js 14 (App Router, TypeScript)
- **Styling**: Tailwind CSS with shadcn/ui components
- **Database**: Supabase (PostgreSQL + Vector storage)
- **Authentication**: Supabase Auth
- **External APIs**: 
  - OpenAI API (topic atomization)
  - arXiv API (paper fetching)
  - Semantic Scholar API (alternative paper source)
- **Deployment**: Vercel (Free Tier compatible)

## Project Structure

```
src/
├── app/
│   ├── actions/          # Server actions
│   │   └── atomizeTopic.ts
│   ├── dashboard/        # Main dashboard page
│   │   └── page.tsx
│   └── globals.css       # Global styles
├── components/
│   ├── ui/              # Reusable UI components
│   ├── TopicTree.tsx    # Concept tree visualization
│   ├── PaperCard.tsx    # Paper display component
│   └── TopicInputDialog.tsx
├── lib/
│   ├── services/        # Business logic services
│   │   └── paperFetcher.ts
│   ├── supabase/        # Database client
│   └── utils.ts         # Utility functions
└── types/               # TypeScript type definitions
```

## Database Schema

The application uses a comprehensive PostgreSQL schema with the following main tables:

- **users**: User profiles linked to Supabase auth
- **topics**: Main PhD research topics
- **concepts**: Hierarchical sub-concepts with recursive relationships
- **papers**: Research paper metadata
- **concept_papers**: Junction table linking concepts to papers
- **user_interactions**: Reading progress and annotations
- **user_library**: Saved papers and personal organization

## Getting Started

### Prerequisites

- Node.js 18+ 
- Supabase account
- OpenAI API key (for topic atomization)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/thesisflow.git
cd thesisflow
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
```bash
cp .env.local.example .env.local
```

4. Configure your environment variables in `.env.local`:
- Add your Supabase project URL and keys
- Add your OpenAI API key
- Configure other optional services

5. Set up the database:
- Run the SQL schema from `database-schema.sql` in your Supabase SQL editor
- Enable Row Level Security (RLS) policies as defined in the schema

6. Run the development server:
```bash
npm run dev
```

7. Open [http://localhost:3000](http://localhost:3000) in your browser

### Deployment

The application is optimized for deployment on Vercel:

1. Push your code to GitHub
2. Connect your repository to Vercel
3. Add your environment variables in Vercel dashboard
4. Deploy!

## Configuration

### Supabase Setup

1. Create a new Supabase project
2. Run the database schema from `database-schema.sql`
3. Enable authentication with email/password
4. Copy the project URL and anon key to your environment variables

### OpenAI Integration

1. Get an API key from [OpenAI Platform](https://platform.openai.com/api-keys)
2. Add it to your environment variables
3. The system will use GPT-4 for topic atomization by default

### Optional Integrations

- **Google Gemini API**: Alternative to OpenAI for topic atomization
- **Semantic Scholar API**: Alternative paper source with different coverage
- **Vercel Analytics**: For usage tracking and performance monitoring

## Usage

### Creating a Research Topic

1. Click the "+" button in the sidebar
2. Enter your broad PhD topic title
3. Optionally provide additional context in the description
4. Click "Create & Atomize" to generate sub-concepts

### Exploring Concepts

1. Select a topic from the dropdown in the sidebar
2. Browse the hierarchical concept tree
3. Click on any concept to view related papers
4. Use the search and filter options to find specific papers

### Managing Papers

1. View papers in list or grid mode
2. Click "Save to Library" to bookmark important papers
3. Use "Mark as Read" to track your reading progress
4. Access reproducible papers through code/data badges

## Development

### Adding New Features

1. Create server actions in `src/app/actions/`
2. Add corresponding UI components in `src/components/`
3. Update the database schema if needed
4. Add proper TypeScript types

### API Integration

The system supports multiple paper sources:
- arXiv API (primary)
- Semantic Scholar API (alternative)
- Custom paper databases

### Customization

- Modify the topic atomization prompt in `atomizeTopic.ts`
- Adjust reproducibility keywords in `paperFetcher.ts`
- Customize the UI theme in `globals.css`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions, issues, or contributions:
- Create an issue in the GitHub repository
- Check the documentation in the `/docs` folder
- Join our community discussions

## Acknowledgments

- Inspired by modern research tools like Notion, Obsidian, and Zotero
- Built with modern React patterns and best practices
- Designed for the academic research workflow

---

**ThesisFlow** - Empowering PhD research through intelligent topic decomposition and paper discovery.