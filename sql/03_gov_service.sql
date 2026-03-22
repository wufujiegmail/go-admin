-- =============================================================
-- 模块：政务服务
-- 说明：政策法规库、政务事项入口、官方办理链接配置及引导日志
-- 执行顺序：第 3 步
-- =============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------
-- 政策法规分类表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `gov_policy_category` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `parent_id`     BIGINT            NOT NULL DEFAULT 0      COMMENT '父分类ID，0 表示顶级',
  `cat_name`      VARCHAR(64)       NOT NULL                COMMENT '分类名称',
  `sort`          INT               NOT NULL DEFAULT 0      COMMENT '排序',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=启用 0=停用',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_parent` (`tenant_id`, `parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='政策法规分类表';

-- -------------------------------------------------------------
-- 政策法规表
-- 包含：物管法、民法典、维修基金使用办法、养犬条例、殡葬条例等
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `gov_policy` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `category_id`   BIGINT            NOT NULL                COMMENT '分类ID（关联 gov_policy_category.id）',
  `title`         VARCHAR(255)      NOT NULL                COMMENT '法规/政策标题',
  `source`        VARCHAR(128)      DEFAULT NULL            COMMENT '来源/发布机关',
  `pub_date`      DATE              DEFAULT NULL            COMMENT '发布日期',
  `effective_date` DATE             DEFAULT NULL            COMMENT '施行日期',
  `content`       LONGTEXT          DEFAULT NULL            COMMENT '正文内容（富文本/Markdown）',
  `attachment_url` VARCHAR(1024)    DEFAULT NULL            COMMENT '附件下载地址',
  `view_count`    BIGINT            NOT NULL DEFAULT 0      COMMENT '浏览次数',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=发布 0=草稿 2=下架',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_cat_status` (`tenant_id`, `category_id`, `status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='政策法规表';

-- -------------------------------------------------------------
-- 政务事项表
-- 包含：户口/身份证办理、居住证办理、车辆违章销号、机动车年检预约等
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `gov_service_item` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `item_name`     VARCHAR(128)      NOT NULL                COMMENT '事项名称',
  `item_icon`     VARCHAR(512)      DEFAULT NULL            COMMENT '事项图标地址',
  `category`      VARCHAR(64)       DEFAULT NULL            COMMENT '事项分类（证件办理/车辆/社保等）',
  `sort`          INT               NOT NULL DEFAULT 0      COMMENT '排序',
  `description`   TEXT              DEFAULT NULL            COMMENT '事项说明',
  `required_docs` TEXT              DEFAULT NULL            COMMENT '所需材料说明',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=上线 0=下线',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_status` (`tenant_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='政务事项配置表';

-- -------------------------------------------------------------
-- 政务事项官方链接/端口配置表
-- 说明：记录各事项对应的官方外部跳转链接
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `gov_service_link` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `service_item_id` BIGINT          NOT NULL                COMMENT '关联事项ID（关联 gov_service_item.id）',
  `link_name`     VARCHAR(128)      NOT NULL                COMMENT '链接/端口名称',
  `link_url`      VARCHAR(1024)     NOT NULL                COMMENT '跳转地址（H5/小程序scheme/API端口）',
  `link_type`     TINYINT           NOT NULL DEFAULT 1      COMMENT '链接类型：1=H5链接 2=小程序跳转 3=电话',
  `platform`      TINYINT           NOT NULL DEFAULT 0      COMMENT '适用平台：0=全部 1=微信小程序 2=H5',
  `sort`          INT               NOT NULL DEFAULT 0      COMMENT '排序',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=启用 0=停用',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_service_item` (`service_item_id`),
  KEY `idx_tenant_status` (`tenant_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='政务事项官方链接配置表';

-- -------------------------------------------------------------
-- 政务点击/引导日志
-- 说明：记录居民点击政务事项的行为数据（用于分析热门事项）
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `gov_service_log` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `user_id`       BIGINT            DEFAULT NULL            COMMENT '操作用户ID（关联 sys_user.user_id）',
  `service_item_id` BIGINT          DEFAULT NULL            COMMENT '事项ID（关联 gov_service_item.id）',
  `service_link_id` BIGINT          DEFAULT NULL            COMMENT '链接ID（关联 gov_service_link.id）',
  `action`        VARCHAR(32)       DEFAULT NULL            COMMENT '操作类型（view=浏览/jump=跳转）',
  `client_ip`     VARCHAR(64)       DEFAULT NULL            COMMENT '客户端IP',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_item` (`tenant_id`, `service_item_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='政务点击/引导日志（用于统计热门事项）';

SET FOREIGN_KEY_CHECKS = 1;
