-- ============================================================================
-- QwikLearn — Supabase schema
-- Run in the Supabase SQL editor, or via `supabase db push`.
-- ============================================================================

create extension if not exists "uuid-ossp";

-- ============================================================================
-- profiles
-- ============================================================================
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  avatar_url text,
  daily_goal_minutes integer default 30,
  default_quiz_difficulty text default 'medium',
  preferred_flashcard_count integer default 20,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================================================
-- study_spaces
-- ============================================================================
create table if not exists study_spaces (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references profiles(id) on delete cascade not null,
  title text not null,
  description text,
  subject text,
  cover_image_url text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================================================
-- study_materials
-- ============================================================================
create table if not exists study_materials (
  id uuid primary key default uuid_generate_v4(),
  study_space_id uuid references study_spaces(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  title text not null,
  material_type text not null check (material_type in ('pdf','text','article','youtube','audio')),
  content text,
  file_url text,
  source_url text,
  created_at timestamptz default now()
);

-- ============================================================================
-- notes
-- ============================================================================
create table if not exists notes (
  id uuid primary key default uuid_generate_v4(),
  study_space_id uuid references study_spaces(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  title text not null,
  content text not null,
  source_material_id uuid references study_materials(id) on delete set null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================================================
-- summaries
-- ============================================================================
create table if not exists summaries (
  id uuid primary key default uuid_generate_v4(),
  study_space_id uuid references study_spaces(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  content text not null,
  summary_length text not null check (summary_length in ('short','medium','detailed')),
  created_at timestamptz default now()
);

-- ============================================================================
-- flashcards
-- ============================================================================
create table if not exists flashcards (
  id uuid primary key default uuid_generate_v4(),
  study_space_id uuid references study_spaces(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  front text not null,
  back text not null,
  difficulty text default 'medium' check (difficulty in ('easy','medium','difficult')),
  last_reviewed_at timestamptz,
  created_at timestamptz default now()
);

-- ============================================================================
-- key_concepts
-- ============================================================================
create table if not exists key_concepts (
  id uuid primary key default uuid_generate_v4(),
  study_space_id uuid references study_spaces(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  name text not null,
  definition text not null,
  simple_explanation text,
  related_topics text[],
  created_at timestamptz default now()
);

-- ============================================================================
-- quizzes / quiz_questions / quiz_attempts
-- ============================================================================
create table if not exists quizzes (
  id uuid primary key default uuid_generate_v4(),
  study_space_id uuid references study_spaces(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  title text not null,
  difficulty text not null check (difficulty in ('easy','medium','hard')),
  created_at timestamptz default now()
);

create table if not exists quiz_questions (
  id uuid primary key default uuid_generate_v4(),
  quiz_id uuid references quizzes(id) on delete cascade not null,
  question text not null,
  question_type text not null check (question_type in ('multiple_choice','true_false')),
  options jsonb,
  correct_answer text not null,
  explanation text
);

create table if not exists quiz_attempts (
  id uuid primary key default uuid_generate_v4(),
  quiz_id uuid references quizzes(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  score integer not null,
  total_questions integer not null,
  completed_at timestamptz default now()
);

-- ============================================================================
-- chat_conversations / chat_messages ("Ask QwikLearn")
-- ============================================================================
create table if not exists chat_conversations (
  id uuid primary key default uuid_generate_v4(),
  study_space_id uuid references study_spaces(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  created_at timestamptz default now()
);

create table if not exists chat_messages (
  id uuid primary key default uuid_generate_v4(),
  conversation_id uuid references chat_conversations(id) on delete cascade not null,
  role text not null check (role in ('user','assistant')),
  content text not null,
  created_at timestamptz default now()
);

-- ============================================================================
-- learning_progress
-- ============================================================================
create table if not exists learning_progress (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references profiles(id) on delete cascade not null,
  study_space_id uuid references study_spaces(id) on delete cascade not null,
  study_time_seconds integer default 0,
  flashcards_reviewed integer default 0,
  quizzes_completed integer default 0,
  updated_at timestamptz default now(),
  unique (user_id, study_space_id)
);

-- ============================================================================
-- Auto-create a profile row whenever a new auth user is created.
--
-- This runs as SECURITY DEFINER on the server, so it works even when the
-- client has no session yet (e.g. "Confirm email" is turned on in
-- Authentication -> Providers -> Email, so signUp() does not return a
-- session until the user clicks the confirmation link). Relying on the
-- client to `upsert` into profiles right after signUp() fails silently
-- in that case, because auth.uid() is null until the session exists —
-- this trigger removes that dependency entirely.
-- ============================================================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', ''))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================================
-- Row Level Security — a user may only ever touch their own rows.
-- ============================================================================
alter table profiles enable row level security;
alter table study_spaces enable row level security;
alter table study_materials enable row level security;
alter table notes enable row level security;
alter table summaries enable row level security;
alter table flashcards enable row level security;
alter table key_concepts enable row level security;
alter table quizzes enable row level security;
alter table quiz_questions enable row level security;
alter table quiz_attempts enable row level security;
alter table chat_conversations enable row level security;
alter table chat_messages enable row level security;
alter table learning_progress enable row level security;

create policy "profiles: select own" on profiles for select using (auth.uid() = id);
create policy "profiles: update own" on profiles for update using (auth.uid() = id);
create policy "profiles: insert own" on profiles for insert with check (auth.uid() = id);

create policy "study_spaces: crud own" on study_spaces
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "study_materials: crud own" on study_materials
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "notes: crud own" on notes
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "summaries: crud own" on summaries
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "flashcards: crud own" on flashcards
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "key_concepts: crud own" on key_concepts
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "quizzes: crud own" on quizzes
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "quiz_questions: via own quiz" on quiz_questions
  for all using (
    exists (select 1 from quizzes q where q.id = quiz_questions.quiz_id and q.user_id = auth.uid())
  ) with check (
    exists (select 1 from quizzes q where q.id = quiz_questions.quiz_id and q.user_id = auth.uid())
  );

create policy "quiz_attempts: crud own" on quiz_attempts
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "chat_conversations: crud own" on chat_conversations
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "chat_messages: via own conversation" on chat_messages
  for all using (
    exists (select 1 from chat_conversations c where c.id = chat_messages.conversation_id and c.user_id = auth.uid())
  ) with check (
    exists (select 1 from chat_conversations c where c.id = chat_messages.conversation_id and c.user_id = auth.uid())
  );

create policy "learning_progress: crud own" on learning_progress
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ============================================================================
-- Storage bucket for uploaded materials
-- ============================================================================
insert into storage.buckets (id, name, public)
values ('study-materials', 'study-materials', false)
on conflict (id) do nothing;

create policy "study-materials: users read own folder"
on storage.objects for select
using (bucket_id = 'study-materials' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "study-materials: users write own folder"
on storage.objects for insert
with check (bucket_id = 'study-materials' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "study-materials: users delete own folder"
on storage.objects for delete
using (bucket_id = 'study-materials' and (storage.foldername(name))[1] = auth.uid()::text);
