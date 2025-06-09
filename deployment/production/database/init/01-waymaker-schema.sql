-- WayMaker AI Database Schema
-- Christian AI Assistant with Biblical Knowledge Base

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "vector";

-- WayMaker specific user profiles
CREATE TABLE IF NOT EXISTS waymaker_user_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    registration_type VARCHAR(20) NOT NULL CHECK (registration_type IN ('individual', 'family_group', 'community_partner')),
    age_range VARCHAR(10),
    language_preference VARCHAR(5) DEFAULT 'en',
    access_tier VARCHAR(10) DEFAULT 'basic' CHECK (access_tier IN ('basic', 'equity', 'paid')),
    verification_status VARCHAR(20) DEFAULT 'pending',
    referral_code VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Family/Group management
CREATE TABLE IF NOT EXISTS waymaker_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_user_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    group_type VARCHAR(20) DEFAULT 'family',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Group members
CREATE TABLE IF NOT EXISTS waymaker_group_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID NOT NULL REFERENCES waymaker_groups(id) ON DELETE CASCADE,
    name VARCHAR(255),
    age_range VARCHAR(10),
    language_preference VARCHAR(5) DEFAULT 'en',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Community partners
CREATE TABLE IF NOT EXISTS waymaker_partners (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_user_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    organization_name VARCHAR(255) NOT NULL,
    organization_type VARCHAR(50),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    estimated_users INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Referral codes
CREATE TABLE IF NOT EXISTS waymaker_referral_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    partner_id UUID NOT NULL REFERENCES waymaker_partners(id) ON DELETE CASCADE,
    code VARCHAR(50) UNIQUE NOT NULL,
    max_uses INTEGER DEFAULT 100,
    current_uses INTEGER DEFAULT 0,
    expiry_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Biblical knowledge base
CREATE TABLE IF NOT EXISTS waymaker_scripture_references (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    book VARCHAR(50) NOT NULL,
    chapter INTEGER NOT NULL,
    verse_start INTEGER NOT NULL,
    verse_end INTEGER,
    version VARCHAR(10) DEFAULT 'NIV',
    text TEXT NOT NULL,
    topic VARCHAR(100),
    age_group VARCHAR(10) DEFAULT 'all',
    embedding VECTOR(1536), -- For semantic search
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Biblical topics and themes
CREATE TABLE IF NOT EXISTS waymaker_biblical_topics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    topic_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    age_appropriate BOOLEAN DEFAULT true,
    parent_topic_id UUID REFERENCES waymaker_biblical_topics(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Link scripture to topics
CREATE TABLE IF NOT EXISTS waymaker_scripture_topics (
    scripture_id UUID NOT NULL REFERENCES waymaker_scripture_references(id) ON DELETE CASCADE,
    topic_id UUID NOT NULL REFERENCES waymaker_biblical_topics(id) ON DELETE CASCADE,
    PRIMARY KEY (scripture_id, topic_id)
);

-- Conversation enhancement for biblical context
CREATE TABLE IF NOT EXISTS waymaker_conversation_context (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL,
    user_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    biblical_context JSONB, -- Store relevant scripture references
    age_adaptation_applied VARCHAR(10),
    spiritual_growth_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Usage analytics for equity tier management
CREATE TABLE IF NOT EXISTS waymaker_usage_analytics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    query_count INTEGER DEFAULT 0,
    tokens_used INTEGER DEFAULT 0,
    access_tier VARCHAR(10),
    PRIMARY KEY (user_id, date)
);

-- Feedback and theological accuracy tracking
CREATE TABLE IF NOT EXISTS waymaker_feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES accounts(id) ON DELETE SET NULL,
    conversation_id UUID,
    message_id UUID,
    feedback_type VARCHAR(20) CHECK (feedback_type IN ('helpful', 'unhelpful', 'theological_concern', 'inappropriate')),
    feedback_text TEXT,
    resolved BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_waymaker_user_profiles_user_id ON waymaker_user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_waymaker_groups_admin_user_id ON waymaker_groups(admin_user_id);
CREATE INDEX IF NOT EXISTS idx_waymaker_group_members_group_id ON waymaker_group_members(group_id);
CREATE INDEX IF NOT EXISTS idx_waymaker_partners_admin_user_id ON waymaker_partners(admin_user_id);
CREATE INDEX IF NOT EXISTS idx_waymaker_referral_codes_code ON waymaker_referral_codes(code);
CREATE INDEX IF NOT EXISTS idx_waymaker_scripture_topic ON waymaker_scripture_references(topic);
CREATE INDEX IF NOT EXISTS idx_waymaker_scripture_age ON waymaker_scripture_references(age_group);
CREATE INDEX IF NOT EXISTS idx_waymaker_conversation_context_user_id ON waymaker_conversation_context(user_id);
CREATE INDEX IF NOT EXISTS idx_waymaker_usage_analytics_user_date ON waymaker_usage_analytics(user_id, date);
CREATE INDEX IF NOT EXISTS idx_waymaker_feedback_type ON waymaker_feedback(feedback_type);

-- Insert initial biblical topics
INSERT INTO waymaker_biblical_topics (topic_name, description, age_appropriate) VALUES
('Prayer', 'Teaching about prayer and communication with God', true),
('Love', 'God''s love and loving others', true),
('Forgiveness', 'God''s forgiveness and forgiving others', true),
('Faith', 'Trust and belief in God', true),
('Salvation', 'Salvation through Jesus Christ', true),
('Discipleship', 'Following Jesus and spiritual growth', true),
('Service', 'Serving God and others', true),
('Wisdom', 'Biblical wisdom and guidance', true),
('Hope', 'Hope in Christ and eternal life', true),
('Peace', 'God''s peace and inner tranquility', true),
('Joy', 'Joy in the Lord', true),
('Obedience', 'Obedience to God''s commands', true),
('Relationships', 'Biblical relationships and community', true),
('Money', 'Biblical stewardship and generosity', true),
('Work', 'Work as service to God', true),
('Family', 'Biblical family values', true),
('Suffering', 'Dealing with trials and suffering', false), -- Needs age consideration
('End Times', 'Prophecy and second coming', false), -- Needs age consideration
('Theology', 'Deep theological concepts', false); -- Adult-focused

-- Sample scripture references (add more as needed)
INSERT INTO waymaker_scripture_references (book, chapter, verse_start, verse_end, version, text, topic, age_group) VALUES
('John', 3, 16, null, 'NIV', 'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.', 'Love', 'all'),
('Matthew', 6, 9, 13, 'NIV', 'This, then, is how you should pray: "Our Father in heaven, hallowed be your name, your kingdom come, your will be done, on earth as it is in heaven. Give us today our daily bread. And forgive us our debts, as we also have forgiven our debtors. And lead us not into temptation, but deliver us from the evil one."', 'Prayer', 'all'),
('Philippians', 4, 13, null, 'NIV', 'I can do all this through him who gives me strength.', 'Faith', 'all'),
('Proverbs', 3, 5, 6, 'NIV', 'Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.', 'Wisdom', 'teen'),
('1 Corinthians', 13, 4, 7, 'NIV', 'Love is patient, love is kind. It does not envy, it does not boast, it is not proud. It does not dishonor others, it is not self-seeking, it is not easily angered, it keeps no record of wrongs. Love does not delight in evil but rejoices with the truth. It always protects, always trusts, always hopes, always perseveres.', 'Love', 'teen'),
('Psalm', 23, 1, 6, 'NIV', 'The Lord is my shepherd, I lack nothing. He makes me lie down in green pastures, he leads me beside quiet waters, he refreshes my soul. He guides me along the right paths for his name''s sake. Even though I walk through the darkest valley, I will fear no evil, for you are with me; your rod and your staff, they comfort me. You prepare a table before me in the presence of my enemies. You anoint my head with oil; my cup overflows. Surely your goodness and love will follow me all the days of my life, and I will dwell in the house of the Lord forever.', 'Peace', 'all');

-- Link scriptures to topics
INSERT INTO waymaker_scripture_topics (scripture_id, topic_id)
SELECT s.id, t.id
FROM waymaker_scripture_references s
JOIN waymaker_biblical_topics t ON s.topic = t.topic_name;

-- Create update timestamp triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_waymaker_user_profiles_updated_at
    BEFORE UPDATE ON waymaker_user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_waymaker_groups_updated_at
    BEFORE UPDATE ON waymaker_groups
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_waymaker_partners_updated_at
    BEFORE UPDATE ON waymaker_partners
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions (adjust as needed)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO waymaker_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO waymaker_user;