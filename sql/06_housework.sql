-- =============================================================
-- 模块：社区家政服务
-- 说明：服务类目、服务人员、工单、派单、状态流转、评价、
--       社区合伙人及结算
-- 执行顺序：第 6 步
-- =============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------
-- 家政服务类目表
-- 包含：清洁保洁、家电维修、缝纫、餐饮帮厨、理发、快递、代跑腿等
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `hs_service_category` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `parent_id`     BIGINT            NOT NULL DEFAULT 0      COMMENT '父分类ID，0 表示顶级',
  `cat_name`      VARCHAR(64)       NOT NULL                COMMENT '类目名称',
  `cat_icon`      VARCHAR(512)      DEFAULT NULL            COMMENT '类目图标地址',
  `sort`          INT               NOT NULL DEFAULT 0      COMMENT '排序',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=启用 0=停用',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_parent` (`tenant_id`, `parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='家政服务类目表';

-- -------------------------------------------------------------
-- 服务人员/队伍表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `hs_provider` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `user_id`       BIGINT            DEFAULT NULL            COMMENT '关联系统用户ID（sys_user.user_id）',
  `real_name`     VARCHAR(64)       NOT NULL                COMMENT '真实姓名',
  `phone`         VARCHAR(20)       NOT NULL                COMMENT '联系电话',
  `gender`        TINYINT           NOT NULL DEFAULT 0      COMMENT '性别：0=未知 1=男 2=女',
  `id_card_masked` VARCHAR(32)      DEFAULT NULL            COMMENT '身份证号（脱敏）',
  `avatar`        VARCHAR(512)      DEFAULT NULL            COMMENT '头像地址',
  `partner_id`    BIGINT            DEFAULT NULL            COMMENT '所属合伙人ID（关联 hs_partner.id）',
  `avg_score`     DECIMAL(3,1)      NOT NULL DEFAULT 5.0    COMMENT '综合评分（1.0-5.0，冗余计算值）',
  `order_count`   INT               NOT NULL DEFAULT 0      COMMENT '完成工单数（冗余）',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=在职 0=离职 2=暂停接单',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_status` (`tenant_id`, `status`),
  KEY `idx_partner_id` (`partner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='家政服务人员/队伍表';

-- -------------------------------------------------------------
-- 服务人员技能关联表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `hs_provider_skill` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `provider_id`   BIGINT            NOT NULL                COMMENT '服务人员ID（关联 hs_provider.id）',
  `category_id`   BIGINT            NOT NULL                COMMENT '服务类目ID（关联 hs_service_category.id）',
  `proficiency`   TINYINT           NOT NULL DEFAULT 1      COMMENT '熟练度：1=入门 2=熟练 3=精通',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_provider_cat` (`provider_id`, `category_id`),
  KEY `idx_tenant_cat` (`tenant_id`, `category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务人员技能/类目关联表';

-- -------------------------------------------------------------
-- 家政工单表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `hs_service_order` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `order_no`      VARCHAR(64)       NOT NULL                COMMENT '工单编号（唯一）',
  `category_id`   BIGINT            NOT NULL                COMMENT '服务类目ID（关联 hs_service_category.id）',
  `user_id`       BIGINT            NOT NULL                COMMENT '下单用户ID（关联 sys_user.user_id）',
  `resident_id`   BIGINT            DEFAULT NULL            COMMENT '居民档案ID（关联 cm_resident.id）',
  `contact_name`  VARCHAR(64)       NOT NULL                COMMENT '联系人姓名',
  `contact_phone` VARCHAR(20)       NOT NULL                COMMENT '联系电话',
  `service_address` VARCHAR(255)    NOT NULL                COMMENT '上门服务地址',
  `appoint_time`  DATETIME          NOT NULL                COMMENT '预约上门时间',
  `description`   TEXT              DEFAULT NULL            COMMENT '需求描述',
  `amount`        DECIMAL(10,2)     DEFAULT NULL            COMMENT '服务费用（元），NULL 表示面议',
  `pay_status`    TINYINT           NOT NULL DEFAULT 0      COMMENT '支付状态：0=未支付 1=已支付 2=已退款',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '工单状态：0=待派单 1=已派单 2=服务中 3=已完成 4=已取消 5=投诉中',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_tenant_status_created` (`tenant_id`, `status`, `created_at`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_appoint_time` (`appoint_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='家政服务工单表';

-- -------------------------------------------------------------
-- 派单记录表
-- 说明：记录系统自动/手工派单过程，一张工单可多次派单（换人）
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `hs_order_dispatch` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `order_id`      BIGINT            NOT NULL                COMMENT '工单ID（关联 hs_service_order.id）',
  `provider_id`   BIGINT            NOT NULL                COMMENT '派单服务人员ID（关联 hs_provider.id）',
  `dispatch_type` TINYINT           NOT NULL DEFAULT 1      COMMENT '派单方式：1=系统自动 2=手工派单',
  `dispatcher_id` BIGINT            DEFAULT NULL            COMMENT '派单操作人ID（手工派单时）',
  `dispatch_at`   DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '派单时间',
  `accept_at`     DATETIME          DEFAULT NULL            COMMENT '服务人员接单时间',
  `reject_at`     DATETIME          DEFAULT NULL            COMMENT '拒单时间',
  `reject_reason` VARCHAR(255)      DEFAULT NULL            COMMENT '拒单原因',
  `is_current`    TINYINT           NOT NULL DEFAULT 1      COMMENT '是否当前有效派单：1=是 0=否',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_provider_id` (`provider_id`),
  KEY `idx_tenant_current` (`tenant_id`, `is_current`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='家政派单记录表';

-- -------------------------------------------------------------
-- 工单状态流转日志表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `hs_order_status_log` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `order_id`      BIGINT            NOT NULL                COMMENT '工单ID（关联 hs_service_order.id）',
  `from_status`   TINYINT           DEFAULT NULL            COMMENT '变更前状态',
  `to_status`     TINYINT           NOT NULL                COMMENT '变更后状态',
  `operator_id`   BIGINT            DEFAULT NULL            COMMENT '操作人用户ID',
  `operator_type` TINYINT           NOT NULL DEFAULT 1      COMMENT '操作人类型：1=系统 2=用户 3=服务人员 4=管理员',
  `remark`        VARCHAR(255)      DEFAULT NULL            COMMENT '备注/原因',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_tenant_created` (`tenant_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='工单状态流转日志';

-- -------------------------------------------------------------
-- 家政服务评价表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `hs_order_review` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `order_id`      BIGINT            NOT NULL                COMMENT '工单ID（关联 hs_service_order.id）',
  `provider_id`   BIGINT            NOT NULL                COMMENT '被评价服务人员ID（关联 hs_provider.id）',
  `reviewer_id`   BIGINT            NOT NULL                COMMENT '评价用户ID（关联 sys_user.user_id）',
  `score`         TINYINT           NOT NULL DEFAULT 5      COMMENT '综合评分（1-5星）',
  `attitude_score` TINYINT          DEFAULT NULL            COMMENT '服务态度评分（1-5星）',
  `skill_score`   TINYINT           DEFAULT NULL            COMMENT '技能评分（1-5星）',
  `content`       TEXT              DEFAULT NULL            COMMENT '评价内容',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=正常 0=已屏蔽',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_provider_id` (`provider_id`),
  KEY `idx_tenant_status` (`tenant_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='家政服务评价表';

-- -------------------------------------------------------------
-- 社区合伙人表
-- 说明：负责管理社区家政服务的合伙人（社区监督指导）
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `hs_partner` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `user_id`       BIGINT            DEFAULT NULL            COMMENT '关联系统用户ID（sys_user.user_id）',
  `partner_name`  VARCHAR(64)       NOT NULL                COMMENT '合伙人/机构名称',
  `contact_name`  VARCHAR(64)       DEFAULT NULL            COMMENT '联系人姓名',
  `contact_phone` VARCHAR(20)       NOT NULL                COMMENT '联系电话',
  `address`       VARCHAR(255)      DEFAULT NULL            COMMENT '地址',
  `commission_rate` DECIMAL(5,4)    NOT NULL DEFAULT 0.1    COMMENT '佣金比例（如 0.1000 表示 10%）',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=合作中 0=停止合作',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_status` (`tenant_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社区家政合伙人表';

-- -------------------------------------------------------------
-- 合伙人结算记录表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `hs_partner_settlement` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `partner_id`    BIGINT            NOT NULL                COMMENT '合伙人ID（关联 hs_partner.id）',
  `period_start`  DATE              NOT NULL                COMMENT '结算周期开始日期',
  `period_end`    DATE              NOT NULL                COMMENT '结算周期结束日期',
  `order_count`   INT               NOT NULL DEFAULT 0      COMMENT '结算工单数',
  `total_amount`  DECIMAL(12,2)     NOT NULL DEFAULT 0      COMMENT '结算服务总金额（元）',
  `commission`    DECIMAL(12,2)     NOT NULL DEFAULT 0      COMMENT '合伙人佣金（元）',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '结算状态：0=待结算 1=已结算 2=已打款',
  `settle_at`     DATETIME          DEFAULT NULL            COMMENT '结算确认时间',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_partner_period` (`partner_id`, `period_start`),
  KEY `idx_tenant_status` (`tenant_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='合伙人结算记录表';

SET FOREIGN_KEY_CHECKS = 1;
