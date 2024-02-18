CREATE TABLE IF NOT EXISTS attachments (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT,				-- name of the file name.pdf
	mode INT,				-- access permissions
	mtime INT,				-- last modification time
	sz INT DEFAULT 0,		-- file size
	data BLOB,				-- content
	page INT DEFAULT 0,
	doc_id INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS documents (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	title TEXT,
	timestamp INT,
	location TEXT,
	last_moved INT,
	taken INT DEFAULT 0
);