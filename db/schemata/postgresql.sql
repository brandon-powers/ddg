CREATE TABLE users (
  id INTEGER NOT NULL,
  name VARCHAR,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,

  PRIMARY KEY(id)
);

CREATE TABLE reports (
  id INTEGER NOT NULL,
  name VARCHAR,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,

  PRIMARY KEY(id)
);

CREATE TABLE user_reports (
  id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  report_id INTEGER NOT NULL,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,

  PRIMARY KEY(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (report_id) REFERENCES reports(id)
);
