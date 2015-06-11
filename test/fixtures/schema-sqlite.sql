CREATE TABLE `schema_migrations` (`filename` varchar(255) NOT NULL PRIMARY KEY);
CREATE TABLE `books` (`id` integer NOT NULL PRIMARY KEY AUTOINCREMENT, `title` varchar(255) NOT NULL, `price` integer DEFAULT (100));
INSERT INTO "schema_migrations" VALUES('20150610133853_create_books.rb');
INSERT INTO "schema_migrations" VALUES('20150610141017_add_price_to_books.rb');
