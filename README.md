# QuoteVault

A complete quote discovery and collection app built with Flutter, BLoC, and Supabase.

## Features

- ✅ Email/password authentication with sign up, login, logout, and password reset
- ✅ Session persistence (stay logged in)
- ✅ User profile screen
- ✅ Browse quotes with pagination and infinite scroll
- ✅ Filter quotes by category (Motivation, Love, Success, Wisdom, Humor)
- ✅ Search quotes by keyword
- ✅ Search/filter by author
- ✅ Pull-to-refresh functionality
- ✅ Save quotes to favorites with cloud sync
- ✅ View all favorited quotes
- ✅ Create custom collections
- ✅ Add/remove quotes from collections
- ✅ Quote of the Day displayed on home screen
- ✅ Daily quote notifications with customizable time
- ✅ Share quotes as text
- ✅ Generate shareable quote cards (3 different styles)
- ✅ Save quote cards as images
- ✅ Dark/Light mode support
- ✅ Multiple themes (Light, Dark, Blue, Green)
- ✅ Font size adjustment
- ✅ Settings persistence

## Tech Stack

- Flutter
- flutter_bloc (State Management)
- Supabase (Auth & Database)
- shared_preferences (Local Storage)
- flutter_local_notifications (Notifications)
- screenshot (Image Generation)
- share_plus (Sharing)
- image_gallery_saver (Save Images)

## Setup Instructions

### 1. Supabase Setup

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to SQL Editor and run the following SQL to create tables:

```sql
CREATE TABLE quotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quote TEXT NOT NULL,
  author TEXT NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  quote_id UUID REFERENCES quotes(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, quote_id)
);

CREATE TABLE collections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE collection_quotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  collection_id UUID REFERENCES collections(id) ON DELETE CASCADE,
  quote_id UUID REFERENCES quotes(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(collection_id, quote_id)
);

ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE collection_quotes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own favorites"
  ON favorites FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own favorites"
  ON favorites FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own favorites"
  ON favorites FOR DELETE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own collections"
  ON collections FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own collections"
  ON collections FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own collections"
  ON collections FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own collections"
  ON collections FOR DELETE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can view collection quotes from their collections"
  ON collection_quotes FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = collection_quotes.collection_id
      AND collections.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert collection quotes to their collections"
  ON collection_quotes FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = collection_quotes.collection_id
      AND collections.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete collection quotes from their collections"
  ON collection_quotes FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = collection_quotes.collection_id
      AND collections.user_id = auth.uid()
    )
  );
```

3. Seed the database with quotes. You can use the Supabase SQL Editor or API to insert 100+ quotes across the 5 categories.

Example seed data:
```sql
INSERT INTO quotes (quote, author, category) VALUES
('The only way to do great work is to love what you do.', 'Steve Jobs', 'Motivation'),
('Life is what happens to you while you''re busy making other plans.', 'John Lennon', 'Wisdom'),
('The future belongs to those who believe in the beauty of their dreams.', 'Eleanor Roosevelt', 'Success'),
('Love yourself first and everything else falls into line.', 'Lucille Ball', 'Love'),
('I''m not arguing, I''m just explaining why I''m right.', 'Unknown', 'Humor');
```

### 2. Update Constants

Update `lib/core/constants/constants.dart` with your Supabase project URL and anon key:

```dart
class AppConstants {
  static const supabaseUrl = 'YOUR_SUPABASE_URL';
  static const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

You can find these in your Supabase project settings under API.

### 3. Install Dependencies

bash
flutter pub get

### 4. Run the App

bash
flutter run

## Project Structure


lib/
├── core/
│   ├── constants/
│   │   ├── constants.dart
│   │   └── notification_service.dart
│   ├── services/
│   │   ├── preferences_service.dart
│   │   └── daily_quote_service.dart
│   └── theme/
│       └── app_theme.dart
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── auth_screen.dart
│   │       ├── profile_screen.dart
│   │       └── bloc/
│   ├── quotes/
│   │   ├── data/
│   │   │   ├── quote_model.dart
│   │   │   └── repo/
│   │   └── presentation/
│   │       ├── home_screen.dart
│   │       ├── favorites_screen.dart
│   │       ├── quote_detail_screen.dart
│   │       ├── quote_card_styles.dart
│   │       └── bloc/
│   ├── collections/
│   │   ├── collections_screen.dart
│   │   ├── collections_bloc.dart
│   │   └── collection_repo.dart
│   └── settings/
│       └── settings_screen.dart
└── main.dart

## AI Tools Used

- Claude (Cursor AI) for code generation and architecture
- Supabase AI for SQL schema generation

## Known Limitations

- Widget implementation not included (requires platform-specific code)
- Image share styles are basic but functional
- Some error messages could be more user-friendly
- Offline state handling is basic

## Notes

- The app requires an active internet connection for authentication and data sync
- Notifications require device permissions
- Image saving requires storage permissions on mobile devices
