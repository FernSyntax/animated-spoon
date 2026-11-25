-- Existing realms were provisioned before the periodic world spawner existed.
-- Give every realm exactly one pending spawn event so live worlds continue to
-- generate new monsters without a manual reset.
INSERT INTO scheduled_events (
    id, realm_id, kind, due_at_ms, priority, payload, status, created_at_ms
)
SELECT
    gen_random_uuid(),
    r.realm_id,
    'monster_spawn',
    now_ms + 900000,
    250,
    '{"seq":0}'::jsonb,
    'pending',
    now_ms
FROM realm_state r
CROSS JOIN (SELECT wall_now_ms() AS now_ms) t
WHERE NOT EXISTS (
    SELECT 1 FROM scheduled_events e
    WHERE e.realm_id = r.realm_id AND e.kind = 'monster_spawn'
);
