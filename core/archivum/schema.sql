CREATE TABLE IF NOT EXISTS sqlar (
	name TEXT PRIMARY KEY,	-- name of the file /[doc_id]/name.pdf
	mode INT,				-- access permissions
	mtime INT,				-- last modification time
	sz INT DEFAULT 0,		-- file size
	data BLOB,				-- content
	page INTEGER DEFAULT 0,
	TEXT etag
);

CREATE TABLE IF NOT EXISTS document (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	title TEXT,
	timestamp INT,
	location TEXT,
	last_moved INT,
	taken INT DEFAULT 0
);

CREATE VIRTUAL TABLE IF NOT EXISTS sqlar_fts
USING FTS5(
	document_id,
	document_title,
	attachment_name,
	attachment_data,
	attachment_etag
);