CREATE TABLE IF NOT EXISTS `users` (
  `id` INTEGER AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `created_at` DATE,
  `updated_at` DATE,

  PRIMARY KEY (`id`)
)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `reports` (
  `id` INTEGER AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `created_at` DATE,
  `updated_at` DATE,

  PRIMARY KEY (`id`)
)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `user_reports` (
  `id` INTEGER AUTO_INCREMENT,
  `user_id` INTEGER,
  `report_id` INTEGER,
  `name` VARCHAR(150) NOT NULL,
  `created_at` DATE,
  `updated_at` DATE,

  PRIMARY KEY (`id`),
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`)
)
ENGINE = InnoDB;
