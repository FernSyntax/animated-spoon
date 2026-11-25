-- Fog of war: visibility is per player per chunk. Entity details and other
-- players' cities in unscouted chunks are hidden by the server before encoding.
CREATE TABLE IF NOT EXISTS player_scouting (
    realm_id TEXT NOT NULL,
    player_id UUID NOT NULL,
    chunk_x INT NOT NULL,
    chunk_y INT NOT NULL,
    scouted_at_ms BIGINT NOT NULL,
    PRIMARY KEY (realm_id, player_id, chunk_x, chunk_y)
);
CREATE INDEX IF NOT EXISTS scouting_player_idx ON player_scouting(realm_id, player_id);
