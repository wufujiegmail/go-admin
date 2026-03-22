-- =============================================================
-- 模块：邻里互助
-- 说明：居民公约、邻里淘（闲置物品认捐/认领/认购）、
--       邻里达人展示、邻里社群管理
-- 执行顺序：第 11 步
-- =============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------
-- 居民公约表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `nei_convention` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `title`         VARCHAR(255)      NOT NULL                COMMENT '公约标题',
  `content`       LONGTEXT          NOT NULL                COMMENT '公约正文（富文本）',
  `version`       VARCHAR(16)       DEFAULT NULL            COMMENT '版本号（如 V2.0）',
  `effective_date` DATE             DEFAULT NULL            COMMENT '施行日期',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=草稿 1=当前有效 2=历史版本',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_status` (`tenant_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='居民公约表';

-- -------------------------------------------------------------
-- 邻里淘（闲置物品）表
-- 说明：支持认捐、认领、认购三种类型
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `nei_idle_item` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `user_id`       BIGINT            NOT NULL                COMMENT '发布用户ID（关联 sys_user.user_id）',
  `title`         VARCHAR(255)      NOT NULL                COMMENT '物品名称/标题',
  `description`   TEXT              DEFAULT NULL            COMMENT '物品描述',
  `img_urls`      TEXT              DEFAULT NULL            COMMENT '物品图片（JSON 数组）',
  `item_type`     TINYINT           NOT NULL DEFAULT 1      COMMENT '类型：1=认捐（免费捐出）2=认领（免费领取）3=认购（有偿出售）',
  `price`         DECIMAL(10,2)     DEFAULT NULL            COMMENT '认购价格（认购类型时填写）',
  `category`      VARCHAR(64)       DEFAULT NULL            COMMENT '物品分类（家电/书籍/衣物/家具/其他）',
  `contact_phone` VARCHAR(20)       DEFAULT NULL            COMMENT '联系电话',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=在售/可领 2=已完成 3=已下架',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_type_status` (`tenant_id`, `item_type`, `status`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='邻里淘闲置物品表';

-- -------------------------------------------------------------
-- 邻里淘交易记录表
-- 说明：记录认捐/认领/认购交易
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `nei_idle_txn` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `item_id`       BIGINT            NOT NULL                COMMENT '物品ID（关联 nei_idle_item.id）',
  `buyer_id`      BIGINT            NOT NULL                COMMENT '认捐/认领/认购方用户ID（关联 sys_user.user_id）',
  `seller_id`     BIGINT            NOT NULL                COMMENT '发布方用户ID',
  `txn_type`      TINYINT           NOT NULL                COMMENT '交易类型：1=认捐 2=认领 3=认购',
  `amount`        DECIMAL(10,2)     DEFAULT NULL            COMMENT '认购金额（认购类型时）',
  `pay_status`    TINYINT           NOT NULL DEFAULT 0      COMMENT '支付状态：0=待支付 1=已支付 2=已退款（认购时有效）',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '交易状态：0=进行中 1=已完成 2=已取消',
  `remark`        VARCHAR(255)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_item_id` (`item_id`),
  KEY `idx_buyer_id` (`buyer_id`),
  KEY `idx_tenant_status_created` (`tenant_id`, `status`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='邻里淘交易记录表';

-- -------------------------------------------------------------
-- 邻里达人表
-- 说明：展示社区居民人才与特色资源
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `nei_talent` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `user_id`       BIGINT            NOT NULL                COMMENT '达人用户ID（关联 sys_user.user_id）',
  `talent_name`   VARCHAR(64)       NOT NULL                COMMENT '达人/昵称',
  `avatar`        VARCHAR(512)      DEFAULT NULL            COMMENT '头像',
  `skill_tags`    VARCHAR(512)      DEFAULT NULL            COMMENT '擅长标签（如 烹饪/摄影/舞蹈/书法，逗号分隔）',
  `intro`         TEXT              DEFAULT NULL            COMMENT '个人介绍',
  `cover_img`     VARCHAR(512)      DEFAULT NULL            COMMENT '封面图',
  `works`         TEXT              DEFAULT NULL            COMMENT '作品/展示链接（JSON 数组）',
  `contact_phone` VARCHAR(20)       DEFAULT NULL            COMMENT '联系电话（公开）',
  `view_count`    BIGINT            NOT NULL DEFAULT 0      COMMENT '浏览次数（冗余）',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=待审核 1=已上线 2=已下线',
  `sort`          INT               NOT NULL DEFAULT 0      COMMENT '排序',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_status` (`tenant_id`, `status`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='邻里达人展示表';

-- -------------------------------------------------------------
-- 邻里社群表
-- 说明：整合广场舞队、摄影队、跑团、读书社、篮球社等
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `nei_group` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `group_name`    VARCHAR(128)      NOT NULL                COMMENT '社群名称',
  `group_type`    VARCHAR(64)       DEFAULT NULL            COMMENT '社群类型（广场舞/摄影/跑步/读书/篮球等）',
  `cover_img`     VARCHAR(512)      DEFAULT NULL            COMMENT '封面图',
  `description`   TEXT              DEFAULT NULL            COMMENT '社群简介',
  `owner_id`      BIGINT            NOT NULL                COMMENT '群主用户ID（关联 sys_user.user_id）',
  `member_count`  INT               NOT NULL DEFAULT 0      COMMENT '成员数（冗余）',
  `max_members`   INT               DEFAULT NULL            COMMENT '最大成员数，NULL 不限',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=待审核 1=正常 2=已解散',
  `sort`          INT               NOT NULL DEFAULT 0      COMMENT '排序',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_type_status` (`tenant_id`, `group_type`, `status`),
  KEY `idx_owner_id` (`owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='邻里社群表';

-- -------------------------------------------------------------
-- 社群成员表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `nei_group_member` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `group_id`      BIGINT            NOT NULL                COMMENT '社群ID（关联 nei_group.id）',
  `user_id`       BIGINT            NOT NULL                COMMENT '成员用户ID（关联 sys_user.user_id）',
  `role`          TINYINT           NOT NULL DEFAULT 1      COMMENT '角色：1=普通成员 2=管理员',
  `join_at`       DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '入群时间',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=正常 0=已退群 2=已踢出',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_group_user` (`group_id`, `user_id`),
  KEY `idx_tenant_user` (`tenant_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社群成员表';

-- -------------------------------------------------------------
-- 社群活动表
-- 说明：社群发起的线下/线上活动
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `nei_group_activity` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `group_id`      BIGINT            NOT NULL                COMMENT '社群ID（关联 nei_group.id）',
  `title`         VARCHAR(255)      NOT NULL                COMMENT '活动标题',
  `description`   TEXT              DEFAULT NULL            COMMENT '活动描述',
  `activity_time` DATETIME          NOT NULL                COMMENT '活动时间',
  `location`      VARCHAR(255)      DEFAULT NULL            COMMENT '活动地点',
  `max_capacity`  INT               DEFAULT NULL            COMMENT '最大参与人数，NULL 不限',
  `signup_count`  INT               NOT NULL DEFAULT 0      COMMENT '已报名人数（冗余）',
  `organizer_id`  BIGINT            NOT NULL                COMMENT '发起人用户ID（关联 sys_user.user_id）',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=草稿 1=报名中 2=进行中 3=已结束 4=已取消',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_group_status` (`group_id`, `status`),
  KEY `idx_tenant_created` (`tenant_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社群活动表';

SET FOREIGN_KEY_CHECKS = 1;
