CREATE TABLE `admins` (
  `id` int(11) NOT NULL auto_increment,
  `email` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `encrypted_password` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `reset_password_token` varchar(255) collate utf8_unicode_ci default NULL,
  `reset_password_sent_at` datetime default NULL,
  `remember_created_at` datetime default NULL,
  `sign_in_count` int(11) default '0',
  `current_sign_in_at` datetime default NULL,
  `last_sign_in_at` datetime default NULL,
  `current_sign_in_ip` varchar(255) collate utf8_unicode_ci default NULL,
  `last_sign_in_ip` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_admins_on_email` (`email`),
  UNIQUE KEY `index_admins_on_reset_password_token` (`reset_password_token`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `categories` (
  `id` int(11) NOT NULL auto_increment,
  `parent_id` int(11) default NULL,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `description` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `source` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_categories_on_parent_id` (`parent_id`)
) ENGINE=MyISAM AUTO_INCREMENT=64 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `category_data` (
  `id` int(11) NOT NULL auto_increment,
  `category_id` int(11) default NULL,
  `response_key` varchar(255) collate utf8_unicode_ci default NULL,
  `collection_id` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `sort_order` int(11) default NULL,
  `source` varchar(255) collate utf8_unicode_ci default NULL,
  `label` varchar(255) collate utf8_unicode_ci default NULL,
  `key_type` varchar(255) collate utf8_unicode_ci default NULL,
  `json_config` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_category_data_on_category_id` (`category_id`),
  KEY `index_category_data_on_response_key` (`response_key`),
  KEY `index_category_data_on_source` (`source`)
) ENGINE=MyISAM AUTO_INCREMENT=386 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `category_placements` (
  `id` int(11) NOT NULL auto_increment,
  `category_id` int(11) default NULL,
  `collection_id` int(11) default NULL,
  `page_id` int(11) default NULL,
  `position` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `layout` varchar(255) collate utf8_unicode_ci default NULL,
  `priority` int(11) default NULL,
  `layout_config` text collate utf8_unicode_ci,
  `title` varchar(255) collate utf8_unicode_ci default NULL,
  `ancestry` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_category_placements_on_ancestry` (`ancestry`),
  KEY `index_category_placements_on_category_id` (`category_id`),
  KEY `index_category_placements_on_collection_id` (`collection_id`),
  KEY `index_category_placements_on_page_id` (`page_id`)
) ENGINE=MyISAM AUTO_INCREMENT=79 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `census_breakdowns` (
  `id` int(11) NOT NULL auto_increment,
  `datatype_id` int(11) default NULL,
  `description` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `collections` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `description` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `esp_responses` (
  `id` int(11) NOT NULL auto_increment,
  `school_id` int(11) NOT NULL,
  `key` varchar(255) collate utf8_unicode_ci default NULL,
  `value` varchar(255) collate utf8_unicode_ci default NULL,
  `active` tinyint(1) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `pages` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `parent_id` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `index_pages_on_parent_id` (`parent_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `rails_admin_histories` (
  `id` int(11) NOT NULL auto_increment,
  `message` text collate utf8_unicode_ci,
  `username` varchar(255) collate utf8_unicode_ci default NULL,
  `item` int(11) default NULL,
  `table` varchar(255) collate utf8_unicode_ci default NULL,
  `month` smallint(6) default NULL,
  `year` bigint(20) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `index_rails_admin_histories` (`item`,`table`,`month`,`year`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `response_values` (
  `id` int(11) NOT NULL auto_increment,
  `response_value` varchar(255) collate utf8_unicode_ci default NULL,
  `response_label` varchar(255) collate utf8_unicode_ci default NULL,
  `collection_id` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `category_id` int(11) default NULL,
  `response_key` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_response_values_on_collection_id` (`collection_id`),
  KEY `index_response_values_on_response_value` (`response_value`)
) ENGINE=MyISAM AUTO_INCREMENT=367 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) collate utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `school` (
  `id` int(11) NOT NULL auto_increment,
  `state` varchar(255) collate utf8_unicode_ci default NULL,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `school_collections` (
  `id` int(11) NOT NULL auto_increment,
  `school_id` int(11) default NULL,
  `collection_id` int(11) default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `state` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `school_profile_configurations` (
  `id` int(11) NOT NULL auto_increment,
  `state` varchar(255) default NULL,
  `configuration_key` varchar(255) NOT NULL,
  `value` blob NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `email` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `encrypted_password` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `reset_password_token` varchar(255) collate utf8_unicode_ci default NULL,
  `reset_password_sent_at` datetime default NULL,
  `remember_created_at` datetime default NULL,
  `sign_in_count` int(11) default '0',
  `current_sign_in_at` datetime default NULL,
  `last_sign_in_at` datetime default NULL,
  `current_sign_in_ip` varchar(255) collate utf8_unicode_ci default NULL,
  `last_sign_in_ip` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `versions` (
  `id` int(11) NOT NULL auto_increment,
  `item_type` varchar(255) collate utf8_unicode_ci NOT NULL,
  `item_id` int(11) NOT NULL,
  `event` varchar(255) collate utf8_unicode_ci NOT NULL,
  `whodunnit` varchar(255) collate utf8_unicode_ci default NULL,
  `object` text collate utf8_unicode_ci,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_versions_on_item_type_and_item_id` (`item_type`,`item_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3408 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('20130820171959');

INSERT INTO schema_migrations (version) VALUES ('20130820172108');

INSERT INTO schema_migrations (version) VALUES ('20130820172209');

INSERT INTO schema_migrations (version) VALUES ('20130820173218');

INSERT INTO schema_migrations (version) VALUES ('20130820182308');

INSERT INTO schema_migrations (version) VALUES ('20130820182454');

INSERT INTO schema_migrations (version) VALUES ('20130820182738');

INSERT INTO schema_migrations (version) VALUES ('20130820233639');

INSERT INTO schema_migrations (version) VALUES ('20130820233707');

INSERT INTO schema_migrations (version) VALUES ('20130820233922');

INSERT INTO schema_migrations (version) VALUES ('20130823200500');

INSERT INTO schema_migrations (version) VALUES ('20130823200624');

INSERT INTO schema_migrations (version) VALUES ('20130823203302');

INSERT INTO schema_migrations (version) VALUES ('20130823203628');

INSERT INTO schema_migrations (version) VALUES ('20130905185137');

INSERT INTO schema_migrations (version) VALUES ('20130905223521');

INSERT INTO schema_migrations (version) VALUES ('20130906014953');

INSERT INTO schema_migrations (version) VALUES ('20130906022357');

INSERT INTO schema_migrations (version) VALUES ('20130909232048');

INSERT INTO schema_migrations (version) VALUES ('20130910011823');

INSERT INTO schema_migrations (version) VALUES ('20130910163926');

INSERT INTO schema_migrations (version) VALUES ('20130911003057');

INSERT INTO schema_migrations (version) VALUES ('20130911193454');

INSERT INTO schema_migrations (version) VALUES ('20130912023707');

INSERT INTO schema_migrations (version) VALUES ('20130912044432');

INSERT INTO schema_migrations (version) VALUES ('20130916205012');

INSERT INTO schema_migrations (version) VALUES ('20130917180916');

INSERT INTO schema_migrations (version) VALUES ('20130917181944');

INSERT INTO schema_migrations (version) VALUES ('20130917224159');

INSERT INTO schema_migrations (version) VALUES ('20130918042153');

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

INSERT INTO schema_migrations (version) VALUES ('20140416190600');

INSERT INTO schema_migrations (version) VALUES ('20140424232817');

INSERT INTO schema_migrations (version) VALUES ('20140429185339');