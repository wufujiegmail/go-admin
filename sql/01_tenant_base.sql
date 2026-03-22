-- =============================================================
-- 模块：租户基础扩展 + 文件资产 + 站内消息
-- 说明：go-admin 已有 sys_user/sys_role/sys_dept 等系统表，
--       本文件仅在已有用户体系基础上补充租户业务扩展表。
--       不重复创建 go-admin 自带系统表。
-- 执行顺序：第 1 步
-- =============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------
-- 租户表
-- 说明：一个租户对应一个社区/小区运营主体
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `biz_tenant` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_code`   VARCHAR(64)       NOT NULL                COMMENT '租户编码（唯一，如社区代码）',
  `tenant_name`   VARCHAR(128)      NOT NULL                COMMENT '租户名称（如：金星北路社区）',
  `logo`          VARCHAR(512)      DEFAULT NULL            COMMENT 'Logo 图片地址',
  `contact_name`  VARCHAR(64)       DEFAULT NULL            COMMENT '联系人姓名',
  `contact_phone` VARCHAR(20)       DEFAULT NULL            COMMENT '联系电话',
  `address`       VARCHAR(255)      DEFAULT NULL            COMMENT '详细地址',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=正常 0=禁用',
  `expired_at`    DATETIME          DEFAULT NULL            COMMENT '租约到期时间，NULL 表示永久',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人（关联 sys_user.user_id）',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间，NULL 表示未删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_code` (`tenant_code`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='租户表';

-- -------------------------------------------------------------
-- 文件资产表
-- 说明：统一管理上传文件元数据（图片/视频/附件等）
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `biz_file_asset` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID（关联 biz_tenant.id）',
  `biz_type`      VARCHAR(64)       DEFAULT NULL            COMMENT '业务类型标识（如 activity_media、notice_attach）',
  `biz_id`        BIGINT            DEFAULT NULL            COMMENT '关联业务记录ID',
  `file_name`     VARCHAR(255)      NOT NULL                COMMENT '原始文件名',
  `file_type`     VARCHAR(64)       DEFAULT NULL            COMMENT '文件 MIME 类型（如 image/jpeg）',
  `file_size`     BIGINT            DEFAULT NULL            COMMENT '文件大小（字节）',
  `file_url`      VARCHAR(1024)     NOT NULL                COMMENT '文件访问地址（OSS/MinIO 路径）',
  `storage_path`  VARCHAR(1024)     DEFAULT NULL            COMMENT '存储路径（服务端内部路径）',
  `sort`          INT               NOT NULL DEFAULT 0      COMMENT '排序，升序',
  `uploader_id`   BIGINT            DEFAULT NULL            COMMENT '上传者用户ID（关联 sys_user.user_id）',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_biz` (`tenant_id`, `biz_type`, `biz_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文件资产表';

-- -------------------------------------------------------------
-- 站内消息表
-- 说明：系统/平台推送消息主体，支持多租户
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `biz_message` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `title`         VARCHAR(255)      NOT NULL                COMMENT '消息标题',
  `content`       TEXT              DEFAULT NULL            COMMENT '消息正文',
  `msg_type`      TINYINT           NOT NULL DEFAULT 1      COMMENT '消息类型：1=系统通知 2=业务提醒 3=活动推送 4=审核结果',
  `sender_id`     BIGINT            DEFAULT NULL            COMMENT '发送人ID（NULL 表示系统自动发送）',
  `push_channel`  TINYINT           NOT NULL DEFAULT 1      COMMENT '推送渠道：1=站内 2=微信小程序 3=短信',
  `send_at`       DATETIME          DEFAULT NULL            COMMENT '计划发送时间，NULL 表示立即发送',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=待发送 1=已发送 2=发送失败',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_status_created` (`tenant_id`, `status`, `created_at`),
  KEY `idx_msg_type` (`msg_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='站内消息主表';

-- -------------------------------------------------------------
-- 消息接收记录表
-- 说明：记录每条消息对应的接收用户及已读状态
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `biz_message_user` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `message_id`    BIGINT            NOT NULL                COMMENT '消息ID（关联 biz_message.id）',
  `user_id`       BIGINT            NOT NULL                COMMENT '接收用户ID（关联 sys_user.user_id）',
  `is_read`       TINYINT           NOT NULL DEFAULT 0      COMMENT '是否已读：0=未读 1=已读',
  `read_at`       DATETIME          DEFAULT NULL            COMMENT '已读时间',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_read` (`tenant_id`, `user_id`, `is_read`),
  KEY `idx_message_id` (`message_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息接收记录表（消息与用户多对多）';

SET FOREIGN_KEY_CHECKS = 1;
