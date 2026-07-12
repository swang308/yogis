import { createClient } from '@supabase/supabase-js';

// Values come from environment variables (see .env.example).
// The publishable key is safe to expose in the browser — Row Level Security
// protects the data.
const url = import.meta.env.PUBLIC_SUPABASE_URL;
const key = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

export const supabase = url && key ? createClient(url, key) : null;
