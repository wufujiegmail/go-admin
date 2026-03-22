-- =============================================================
-- 模块：社区公告与活动
-- 说明：公告（定向推送）、活动（报名/评价/相册）、文化宣传
-- 执行顺序：第 4 步
-- =============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------
-- 社区公告表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `com_notice` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `title`         VARCHAR(255)      NOT NULL                COMMENT '公告标题',
  `content`       LONGTEXT          DEFAULT NULL            COMMENT '公告正文（富文本）',
  `notice_type`   TINYINT           NOT NULL DEFAULT 1      COMMENT '公告类型：1=普通公告 2=紧急通知 3=政策宣传',
  `cover_img`     VARCHAR(512)      DEFAULT NULL            COMMENT '封面图地址',
  `publish_at`    DATETIME          DEFAULT NULL            COMMENT '发布时间（支持定时发布）',
  `expire_at`     DATETIME          DEFAULT NULL            COMMENT '过期时间，NULL 表示长期有效',
  `is_top`        TINYINT           NOT NULL DEFAULT 0      COMMENT '是否置顶：1=是 0=否',
  `view_count`    BIGINT            NOT NULL DEFAULT 0      COMMENT '浏览次数',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=草稿 1=已发布 2=已下架',
  `author_id`     BIGINT            DEFAULT NULL            COMMENT '作者用户ID（关联 sys_user.user_id）',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_status_created` (`tenant_id`, `status`, `created_at`),
  KEY `idx_publish_at` (`publish_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社区公告表';

-- -------------------------------------------------------------
-- 公告投放目标表
-- 说明：支持按标签/楼栋/角色定向推送公告
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `com_notice_target` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `notice_id`     BIGINT            NOT NULL                COMMENT '公告ID（关联 com_notice.id）',
  `target_type`   TINYINT           NOT NULL                COMMENT '投放目标类型：1=标签 2=楼栋 3=角色 4=全体',
  `target_id`     BIGINT            DEFAULT NULL            COMMENT '目标ID（对应 cm_tag.id / cm_house.building_no 等）',
  `target_value`  VARCHAR(255)      DEFAULT NULL            COMMENT '目标标识值（当 target_id 不适用时使用）',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_notice_id` (`notice_id`),
  KEY `idx_tenant_target` (`tenant_id`, `target_type`, `target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='公告投放目标表（支持点对点/按标签/楼栋推送）';

-- -------------------------------------------------------------
-- 公告阅读回执表
-- 说明：记录用户已读状态，支持统计公告触达率
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `com_notice_read` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `notice_id`     BIGINT            NOT NULL                COMMENT '公告ID（关联 com_notice.id）',
  `user_id`       BIGINT            NOT NULL                COMMENT '用户ID（关联 sys_user.user_id）',
  `read_at`       DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '阅读时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_notice_user` (`notice_id`, `user_id`),
  KEY `idx_tenant_user` (`tenant_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='公告阅读回执表';

-- -------------------------------------------------------------
-- 社区活动表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `com_activity` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `title`         VARCHAR(255)      NOT NULL                COMMENT '活动名称',
  `cover_img`     VARCHAR(512)      DEFAULT NULL            COMMENT '封面图地址',
  `activity_type` TINYINT           NOT NULL DEFAULT 1      COMMENT '活动类型：1=文化活动 2=公益活动 3=体育活动 4=宣传教育 5=其他',
  `description`   LONGTEXT          DEFAULT NULL            COMMENT '活动详情（富文本）',
  `location`      VARCHAR(255)      DEFAULT NULL            COMMENT '活动地点',
  `start_time`    DATETIME          NOT NULL                COMMENT '活动开始时间',
  `end_time`      DATETIME          NOT NULL                COMMENT '活动结束时间',
  `signup_start`  DATETIME          DEFAULT NULL            COMMENT '报名开始时间',
  `signup_end`    DATETIME          DEFAULT NULL            COMMENT '报名截止时间',
  `max_capacity`  INT               DEFAULT NULL            COMMENT '最大参与人数，NULL 表示不限',
  `signup_count`  INT               NOT NULL DEFAULT 0      COMMENT '已报名人数（冗余计数）',
  `is_review`     TINYINT           NOT NULL DEFAULT 0      COMMENT '是否需要审核报名：1=是 0=否',
  `organizer`     VARCHAR(128)      DEFAULT NULL            COMMENT '主办方',
  `contact_phone` VARCHAR(20)       DEFAULT NULL            COMMENT '活动联系电话',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=草稿 1=报名中 2=进行中 3=已结束 4=已取消',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_status_start` (`tenant_id`, `status`, `start_time`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社区活动表';

-- -------------------------------------------------------------
-- 活动报名表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `com_activity_signup` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `activity_id`   BIGINT            NOT NULL                COMMENT '活动ID（关联 com_activity.id）',
  `user_id`       BIGINT            NOT NULL                COMMENT '报名用户ID（关联 sys_user.user_id）',
  `resident_id`   BIGINT            DEFAULT NULL            COMMENT '居民档案ID（关联 cm_resident.id）',
  `contact_name`  VARCHAR(64)       DEFAULT NULL            COMMENT '联系人姓名',
  `contact_phone` VARCHAR(20)       DEFAULT NULL            COMMENT '联系电话',
  `signup_count`  INT               NOT NULL DEFAULT 1      COMMENT '报名人数（家庭报名时可>1）',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '报名状态：0=待审核 1=已通过 2=已拒绝 3=已取消 4=已签到',
  `review_remark` VARCHAR(255)      DEFAULT NULL            COMMENT '审核备注',
  `checkin_at`    DATETIME          DEFAULT NULL            COMMENT '签到时间',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '报名时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_activity_status` (`activity_id`, `status`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_tenant_created` (`tenant_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动报名表';

-- -------------------------------------------------------------
-- 活动评价表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `com_activity_review` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `activity_id`   BIGINT            NOT NULL                COMMENT '活动ID（关联 com_activity.id）',
  `user_id`       BIGINT            NOT NULL                COMMENT '评价用户ID（关联 sys_user.user_id）',
  `signup_id`     BIGINT            DEFAULT NULL            COMMENT '报名记录ID（关联 com_activity_signup.id）',
  `score`         TINYINT           NOT NULL DEFAULT 5      COMMENT '评分（1-5星）',
  `content`       TEXT              DEFAULT NULL            COMMENT '评价内容',
  `is_anonymous`  TINYINT           NOT NULL DEFAULT 0      COMMENT '是否匿名：1=是 0=否',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=正常 0=隐藏',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_activity_id` (`activity_id`),
  KEY `idx_tenant_status` (`tenant_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动评价表';

-- -------------------------------------------------------------
-- 活动媒体资源表（照片/视频）
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `com_activity_media` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `activity_id`   BIGINT            NOT NULL                COMMENT '活动ID（关联 com_activity.id）',
  `media_type`    TINYINT           NOT NULL DEFAULT 1      COMMENT '媒体类型：1=图片 2=视频',
  `media_url`     VARCHAR(1024)     NOT NULL                COMMENT '媒体文件地址',
  `thumbnail_url` VARCHAR(1024)     DEFAULT NULL            COMMENT '缩略图地址（视频封面/图片缩略）',
  `sort`          INT               NOT NULL DEFAULT 0      COMMENT '排序',
  `uploader_id`   BIGINT            DEFAULT NULL            COMMENT '上传者用户ID',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=正常 0=隐藏',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
  PRIMARY KEY (`id`),
  KEY `idx_activity_type` (`activity_id`, `media_type`, `sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动媒体资源表（照片/视频）';

-- -------------------------------------------------------------
-- 文化宣传内容表
-- 说明：社区文化宣传、教育内容管理（可纳入活动板块）
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `com_publicity` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `title`         VARCHAR(255)      NOT NULL                COMMENT '标题',
  `cover_img`     VARCHAR(512)      DEFAULT NULL            COMMENT '封面图地址',
  `content`       LONGTEXT          DEFAULT NULL            COMMENT '内容（富文本）',
  `pub_type`      TINYINT           NOT NULL DEFAULT 1      COMMENT '宣传类型：1=文化宣传 2=安全教育 3=法制宣传 4=健康科普',
  `view_count`    BIGINT            NOT NULL DEFAULT 0      COMMENT '浏览次数',
  `publish_at`    DATETIME          DEFAULT NULL            COMMENT '发布时间',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=草稿 1=已发布 2=已下架',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_type_status` (`tenant_id`, `pub_type`, `status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文化宣传内容表';

SET FOREIGN_KEY_CHECKS = 1;
