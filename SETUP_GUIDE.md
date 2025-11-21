# ThesisFlow Setup Guide

This guide will walk you through setting up ThesisFlow from scratch, including database configuration, API keys, and deployment.

## Prerequisites

Before you begin, ensure you have:
- Node.js 18 or higher
- A Supabase account (free tier works)
- An OpenAI API key (for topic atomization)
- Git installed on your system

## Step 1: Project Setup

### 1.1 Clone and Install

```bash
# Clone the repository
git clone https://github.com/yourusername/thesisflow.git
cd thesisflow

# Install dependencies
npm install
```

### 1.2 Environment Configuration

```bash
# Copy the environment template
cp .env.local.example .env.local
```

Edit `.env.local` with your configuration:

```env
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
SUPABASE_PROJECT_ID=your-project-id

# OpenAI Configuration
OPENAI_API_KEY=sk-your-openai-api-key

# Optional: Alternative AI services
GEMINI_API_KEY=your-gemini-api-key
SEMANTIC_SCHOLAR_API_KEY=your-semantic-scholar-key
```

## Step 2: Supabase Database Setup

### 2.1 Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Note down your project URL and API keys
3. Wait for the project to initialize (takes 1-2 minutes)

### 2.2 Run Database Schema

1. Open your Supabase dashboard
2. Go to "SQL Editor" in the left sidebar
3. Copy the entire contents of `database-schema.sql`
4. Paste it into the SQL editor and run
5. The schema will create all necessary tables with proper relationships

### 2.3 Enable Row Level Security (RLS)

The schema includes RLS policies that automatically secure your data. No additional configuration needed.

### 2.4 Set up Authentication

1. Go to "Authentication" in Supabase dashboard
2. Click "Providers" in the left sidebar
3. Enable "Email" provider (or others as needed)
4. Configure email templates if desired

## Step 3: API Configuration

### 3.1 OpenAI API Setup

1. Go to [OpenAI Platform](https://platform.openai.com)
2. Create an account and add payment method
3. Generate an API key
4. Add it to your `.env.local` file

### 3.2 Optional: Alternative APIs

**Google Gemini API** (free tier available):
1. Go to [Google AI Studio](https://makersuite.google.com)
2. Create an API key
3. Add to `.env.local`

**Semantic Scholar API** (free):
1. Go to [Semantic Scholar API](https://api.semanticscholar.org/)
2. Sign up for API access
3. Add API key to `.env.local`

## Step 4: Development

### 4.1 Run Development Server

```bash
npm run dev
```

The application will be available at `http://localhost:3000`

### 4.2 Test the Setup

1. Create a new account or sign in
2. Click the "+" button to create a new research topic
3. Enter a topic like "Machine Learning in Healthcare"
4. The system should atomize it into sub-concepts
5. Click on concepts to see related papers

### 4.3 Database Type Generation

Generate TypeScript types from your database:

```bash
npm run db:generate
```

This creates `src/lib/database.types.ts` with type-safe database operations.

## Step 5: Customization

### 5.1 Topic Atomization Prompt

Edit `src/app/actions/atomizeTopic.ts` to customize how topics are broken down:

```typescript
// Modify the system prompt for different research domains
const systemPrompt = `You are a PhD research assistant specialized in [YOUR_DOMAIN]. 
Break down topics into hierarchical sub-concepts...`;
```

### 5.2 Reproducibility Keywords

Update keywords in `src/lib/services/paperFetcher.ts`:

```typescript
const REPRODUCIBILITY_KEYWORDS = {
  code: [
    'github.com', 'gitlab.com', 'your-custom-repo.com',
    // ... add your keywords
  ],
  datasets: [
    'dataset', 'kaggle', 'your-data-platform',
    // ... add your keywords
  ]
};
```

### 5.3 UI Theming

Customize the appearance in `src/app/globals.css`:

```css
/* Modify CSS variables for different themes */
:root {
  --primary: 222.2 47.4% 11.2%; /* Your primary color */
  --background: 0 0% 100%; /* Background color */
  /* ... other variables */
}
```

## Step 6: Deployment

### 6.1 Vercel Deployment (Recommended)

1. Push your code to GitHub
2. Go to [Vercel](https://vercel.com)
3. Import your GitHub repository
4. Add environment variables in Vercel dashboard
5. Deploy!

### 6.2 Environment Variables in Vercel

Add these to your Vercel project settings:
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `OPENAI_API_KEY`
- Any other API keys you're using

### 6.3 Build Configuration

The build process is automatic. Vercel will:
- Install dependencies
- Run `npm run build`
- Deploy the optimized application

## Troubleshooting

### Common Issues

**Database Connection Errors**
- Check your Supabase URL and keys
- Ensure RLS policies are properly set
- Verify network connectivity

**OpenAI API Errors**
- Check your API key is valid
- Ensure you have credits in your account
- Verify the API key has proper permissions

**Build Failures**
- Check TypeScript errors with `npx tsc --noEmit`
- Ensure all dependencies are installed
- Verify environment variables are set

**Authentication Issues**
- Check Supabase auth provider settings
- Verify email confirmation settings
- Check for CORS issues in browser console

### Getting Help

1. Check the logs in your terminal/browser console
2. Verify all environment variables are set correctly
3. Test database connection with Supabase dashboard
4. Review the schema and ensure all tables were created
5. Check API key permissions and billing status

## Advanced Configuration

### Performance Optimization

1. **Database Indexes**: The schema includes optimized indexes
2. **Caching**: Implement Redis for paper caching
3. **CDN**: Use Vercel's built-in CDN for assets

### Security

1. **API Key Security**: Never commit API keys to git
2. **Database Security**: RLS policies are pre-configured
3. **Rate Limiting**: Implement rate limiting for API calls

### Scaling

1. **Database**: Upgrade Supabase plan for more resources
2. **API Limits**: Monitor OpenAI usage and upgrade if needed
3. **Caching**: Implement caching for frequently accessed papers

## Next Steps

After successful setup, consider:

1. **User Feedback**: Implement feedback collection
2. **Analytics**: Add usage tracking
3. **Collaboration**: Enable sharing between researchers
4. **Export**: Add paper export functionality
5. **Integration**: Connect with reference managers

## Support

For additional help:
- Check the main README.md
- Review the code comments
- Create an issue in the repository
- Join the community discussions

---

**Congratulations!** You now have a fully functional ThesisFlow instance. Happy researching! 🎓