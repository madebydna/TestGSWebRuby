CREATE TABLE `admins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL DEFAULT '',
  `encrypted_password` varchar(255) NOT NULL DEFAULT '',
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) DEFAULT NULL,
  `last_sign_in_ip` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_admins_on_email` (`email`),
  UNIQUE KEY `index_admins_on_reset_password_token` (`reset_password_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `source` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_categories_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `category_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) DEFAULT NULL,
  `response_key` varchar(255) DEFAULT NULL,
  `collection_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `source` varchar(255) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_category_data_on_category_id` (`category_id`),
  KEY `index_category_data_on_response_key` (`response_key`),
  KEY `index_category_data_on_source` (`source`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `category_placements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) DEFAULT NULL,
  `collection_id` int(11) DEFAULT NULL,
  `page_id` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `layout` varchar(255) DEFAULT NULL,
  `priority` int(11) DEFAULT NULL,
  `layout_config` text,
  `title` varchar(255) DEFAULT NULL,
  `ancestry` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_category_placements_on_category_id` (`category_id`),
  KEY `index_category_placements_on_collection_id` (`collection_id`),
  KEY `index_category_placements_on_page_id` (`page_id`),
  KEY `index_category_placements_on_ancestry` (`ancestry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `collections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `parent_id` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pages_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `rails_admin_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message` text,
  `username` varchar(255) DEFAULT NULL,
  `item` int(11) DEFAULT NULL,
  `table` varchar(255) DEFAULT NULL,
  `month` smallint(6) DEFAULT NULL,
  `year` bigint(20) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_rails_admin_histories` (`item`,`table`,`month`,`year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `response_values` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `response_value` varchar(255) DEFAULT NULL,
  `response_label` varchar(255) DEFAULT NULL,
  `collection_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `category_id` int(11) DEFAULT NULL,
  `response_key` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_response_values_on_response_value` (`response_value`),
  KEY `index_response_values_on_collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `school_profile_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` varchar(255) DEFAULT NULL,
  `configuration_key` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_type` varchar(255) NOT NULL,
  `item_id` int(11) NOT NULL,
  `event` varchar(255) NOT NULL,
  `whodunnit` varchar(255) DEFAULT NULL,
  `object` text,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_versions_on_item_type_and_item_id` (`item_type`,`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20130820171959');

INSERT INTO schema_migrations (version) VALUES ('20130820172108');

INSERT INTO schema_migrations (version) VALUES ('20130820173218');

INSERT INTO schema_migrations (version) VALUES ('20130820182454');

INSERT INTO schema_migrations (version) VALUES ('20130820233707');

INSERT INTO schema_migrations (version) VALUES ('20130820233922');

INSERT INTO schema_migrations (version) VALUES ('20130823203302');

INSERT INTO schema_migrations (version) VALUES ('20130823203628');

INSERT INTO schema_migrations (version) VALUES ('20130905185137');

INSERT INTO schema_migrations (version) VALUES ('20130905223521');

INSERT INTO schema_migrations (version) VALUES ('20130906014953');

INSERT INTO schema_migrations (version) VALUES ('20130906022357');

INSERT INTO schema_migrations (version) VALUES ('20130910011823');

INSERT INTO schema_migrations (version) VALUES ('20130910163926');

INSERT INTO schema_migrations (version) VALUES ('20130911003057');

INSERT INTO schema_migrations (version) VALUES ('20130916205012');

INSERT INTO schema_migrations (version) VALUES ('20130917181944');

INSERT INTO schema_migrations (version) VALUES ('20130917224159');

INSERT INTO schema_migrations (version) VALUES ('20131114184219');

INSERT INTO schema_migrations (version) VALUES ('20131114194531');

INSERT INTO schema_migrations (version) VALUES ('20131218080243');

INSERT INTO schema_migrations (version) VALUES ('20131218080556');

INSERT INTO schema_migrations (version) VALUES ('20131223230143');

INSERT INTO schema_migrations (version) VALUES ('20131223230300');

INSERT INTO schema_migrations (version) VALUES ('20131224043314');

INSERT INTO schema_migrations (version) VALUES ('20140114185644');

INSERT INTO schema_migrations (version) VALUES ('20140114224135');

INSERT INTO schema_migrations (version) VALUES ('20140324164349');