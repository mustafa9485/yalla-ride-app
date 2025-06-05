-- Database Schema for Yalla Ride (Supabase PostgreSQL)

-- Users Table (managed by Supabase Auth, extend with profiles)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  phone_number TEXT UNIQUE,
  user_type TEXT NOT NULL DEFAULT 'passenger', -- 'passenger' or 'driver'
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Function to automatically create a profile when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, phone_number) -- Assuming phone is used for signup
  VALUES (new.id, new.phone);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call the function after user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Drivers Table (extends profiles)
CREATE TABLE drivers (
  profile_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  vehicle_model TEXT,
  vehicle_plate TEXT UNIQUE,
  is_verified BOOLEAN DEFAULT false NOT NULL,
  is_active BOOLEAN DEFAULT false NOT NULL, -- Driver availability status
  current_location GEOGRAPHY(Point, 4326), -- For storing driver location
  rating NUMERIC(2, 1) DEFAULT 5.0,
  wallet_balance NUMERIC(10, 2) DEFAULT 25000.00 NOT NULL, -- Initial balance as per specs
  is_plus_subscriber BOOLEAN DEFAULT false NOT NULL,
  plus_subscription_expires_at TIMESTAMPTZ,
  city_trips_since_payment INT DEFAULT 0 NOT NULL,
  outofcity_trips_since_payment INT DEFAULT 0 NOT NULL,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);
-- Add index for location
CREATE INDEX drivers_location_idx ON drivers USING GIST (current_location);

-- Rides Table
CREATE TYPE ride_status AS ENUM (
  'pending', -- Waiting for driver
  'accepted', -- Driver accepted
  'arrived', -- Driver arrived at pickup
  'started', -- Ride in progress
  'completed', -- Ride finished
  'cancelled_passenger',
  'cancelled_driver',
  'no_drivers_found'
);

CREATE TABLE rides (
  id BIGSERIAL PRIMARY KEY,
  passenger_id UUID NOT NULL REFERENCES profiles(id),
  driver_id UUID REFERENCES profiles(id), -- Nullable until accepted
  pickup_location_name TEXT NOT NULL,
  destination_location_name TEXT NOT NULL,
  -- pickup_coords GEOGRAPHY(Point, 4326), -- Optional: Store exact coords
  -- destination_coords GEOGRAPHY(Point, 4326), -- Optional: Store exact coords
  ride_type TEXT NOT NULL, -- Matches types in functional_specs.md
  estimated_price NUMERIC(10, 2) NOT NULL,
  final_price NUMERIC(10, 2), -- Set on completion
  status ride_status DEFAULT 'pending' NOT NULL,
  payment_method TEXT DEFAULT 'cash', -- 'cash', 'zaincash'
  passenger_rating INT, -- Rating given by driver
  driver_rating INT, -- Rating given by passenger
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
  accepted_at TIMESTAMPTZ,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ
);

-- Enable Row Level Security (RLS) for all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE rides ENABLE ROW LEVEL SECURITY;

-- RLS Policies (Examples - Needs refinement based on exact logic)
-- Profiles: Users can only see/edit their own profile
CREATE POLICY "Allow own profile read" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Allow own profile update" ON profiles FOR UPDATE USING (auth.uid() = id);

-- Drivers: Users can see basic driver info, drivers can update their own info
CREATE POLICY "Allow all read access to basic driver info" ON drivers FOR SELECT USING (true);
CREATE POLICY "Allow driver to update own info" ON drivers FOR UPDATE USING (auth.uid() = profile_id);

-- Rides: Passengers see their rides, Drivers see rides assigned to them or pending rides
CREATE POLICY "Passengers can see their own rides" ON rides FOR SELECT USING (auth.uid() = passenger_id);
CREATE POLICY "Drivers can see assigned/pending rides" ON rides FOR SELECT USING (
  (driver_id IS NULL AND status = 'pending') OR -- See pending rides (needs refinement based on location/logic)
  (auth.uid() = driver_id)
);
CREATE POLICY "Passengers can insert their own rides" ON rides FOR INSERT WITH CHECK (auth.uid() = passenger_id);
CREATE POLICY "Drivers can update assigned rides" ON rides FOR UPDATE USING (auth.uid() = driver_id);
CREATE POLICY "Passengers can update their own rides (e.g., cancel, rate)" ON rides FOR UPDATE USING (auth.uid() = passenger_id);

-- Enable Realtime for the rides table
-- (Done via Supabase Dashboard UI or command)
-- alter publication supabase_realtime add table rides;


