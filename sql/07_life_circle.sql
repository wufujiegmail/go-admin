-- =============================================================
-- 模块：生活圈（电话黄页、商户管理、场馆预约）
-- 说明：整合便民联系电话、辖区商户入驻审核与诚信评价、
--       公共场馆时段预约
-- 执行顺序：第 7 步
-- =============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------
-- 常用电话（电话黄页）表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `life_phonebook` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `category`      VARCHAR(64)       DEFAULT NULL            COMMENT '分类（如 急救/物业/政务/商户等）',
  `name`          VARCHAR(128)      NOT NULL                COMMENT '名称/机构',
  `phone`         VARCHAR(50)       NOT NULL                COMMENT '联系电话（支持多号 逗号分隔）',
  `address`       VARCHAR(255)      DEFAULT NULL            COMMENT '地址',
  `sort`          INT               NOT NULL DEFAULT 0      COMMENT '排序',
  `is_emergency`  TINYINT           NOT NULL DEFAULT 0      COMMENT '是否紧急联系：1=是 0=否',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=启用 0=停用',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_cat_status` (`tenant_id`, `category`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='常用电话黄页表';

-- -------------------------------------------------------------
-- 商户档案表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `life_merchant` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `merchant_name` VARCHAR(128)      NOT NULL                COMMENT '商户名称',
  `merchant_type` VARCHAR(64)       DEFAULT NULL            COMMENT '商户类型（餐饮/零售/服务/共建等）',
  `logo`          VARCHAR(512)      DEFAULT NULL            COMMENT 'Logo 地址',
  `contact_name`  VARCHAR(64)       DEFAULT NULL            COMMENT '联系人',
  `contact_phone` VARCHAR(20)       DEFAULT NULL            COMMENT '联系电话',
  `address`       VARCHAR(255)      DEFAULT NULL            COMMENT '地址',
  `lng`           DECIMAL(11,7)     DEFAULT NULL            COMMENT '经度',
  `lat`           DECIMAL(11,7)     DEFAULT NULL            COMMENT '纬度',
  `description`   TEXT              DEFAULT NULL            COMMENT '商户简介',
  `user_id`       BIGINT            DEFAULT NULL            COMMENT '关联商户账号用户ID（sys_user.user_id）',
  `credit_score`  DECIMAL(5,2)      NOT NULL DEFAULT 100.00 COMMENT '诚信分（0-100，冗余）',
  `avg_rating`    DECIMAL(3,1)      NOT NULL DEFAULT 5.0    COMMENT '评价均分（1.0-5.0，冗余）',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=待审核 1=正常 2=已驳回 3=已暂停 4=已注销',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_type_status` (`tenant_id`, `merchant_type`, `status`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商户档案表';

-- -------------------------------------------------------------
-- 商户入驻申请表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `life_merchant_apply` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `merchant_id`   BIGINT            DEFAULT NULL            COMMENT '审核通过后关联的商户ID（关联 life_merchant.id）',
  `apply_name`    VARCHAR(128)      NOT NULL                COMMENT '申请商户名称',
  `merchant_type` VARCHAR(64)       DEFAULT NULL            COMMENT '商户类型',
  `contact_name`  VARCHAR(64)       NOT NULL                COMMENT '联系人姓名',
  `contact_phone` VARCHAR(20)       NOT NULL                COMMENT '联系电话',
  `address`       VARCHAR(255)      DEFAULT NULL            COMMENT '经营地址',
  `business_license` VARCHAR(512)   DEFAULT NULL            COMMENT '营业执照图片地址',
  `description`   TEXT              DEFAULT NULL            COMMENT '商户简介/申请说明',
  `user_id`       BIGINT            NOT NULL                COMMENT '申请用户ID（关联 sys_user.user_id）',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '申请状态：0=待审核 1=审核中 2=已通过 3=已驳回',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_status` (`tenant_id`, `status`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商户入驻申请表';

-- -------------------------------------------------------------
-- 商户审核记录表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `life_merchant_audit` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `apply_id`      BIGINT            NOT NULL                COMMENT '申请ID（关联 life_merchant_apply.id）',
  `auditor_id`    BIGINT            NOT NULL                COMMENT '审核人用户ID（关联 sys_user.user_id）',
  `audit_result`  TINYINT           NOT NULL                COMMENT '审核结果：1=通过 2=驳回',
  `audit_remark`  VARCHAR(512)      DEFAULT NULL            COMMENT '审核意见',
  `audit_at`      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '审核时间',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_apply_id` (`apply_id`),
  KEY `idx_tenant_result` (`tenant_id`, `audit_result`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商户入驻审核记录表';

-- -------------------------------------------------------------
-- 商户诚信评价分记录表
-- 说明：社区对商户的诚信评价（区别于居民评价 life_merchant_review）
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `life_merchant_credit` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `merchant_id`   BIGINT            NOT NULL                COMMENT '商户ID（关联 life_merchant.id）',
  `operator_id`   BIGINT            NOT NULL                COMMENT '操作人用户ID（关联 sys_user.user_id）',
  `change_val`    DECIMAL(6,2)      NOT NULL                COMMENT '诚信分变化值（正/负）',
  `score_after`   DECIMAL(5,2)      NOT NULL                COMMENT '变更后诚信分快照',
  `reason`        VARCHAR(255)      NOT NULL                COMMENT '扣/加分原因',
  `evidence_url`  VARCHAR(1024)     DEFAULT NULL            COMMENT '佐证材料地址',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  PRIMARY KEY (`id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_tenant_created` (`tenant_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商户诚信评价分变更记录表';

-- -------------------------------------------------------------
-- 居民对商户的评价表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `life_merchant_review` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `merchant_id`   BIGINT            NOT NULL                COMMENT '商户ID（关联 life_merchant.id）',
  `user_id`       BIGINT            NOT NULL                COMMENT '评价用户ID（关联 sys_user.user_id）',
  `score`         TINYINT           NOT NULL DEFAULT 5      COMMENT '综合评分（1-5星）',
  `content`       TEXT              DEFAULT NULL            COMMENT '评价内容',
  `img_urls`      TEXT              DEFAULT NULL            COMMENT '评价图片地址列表（JSON 数组）',
  `is_anonymous`  TINYINT           NOT NULL DEFAULT 0      COMMENT '是否匿名：1=是 0=否',
  `reply`         TEXT              DEFAULT NULL            COMMENT '商户回复',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=正常 0=已屏蔽',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_merchant_status` (`merchant_id`, `status`),
  KEY `idx_tenant_created` (`tenant_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='居民对商户评价表';

-- -------------------------------------------------------------
-- 场馆资源表
-- 说明：社区公共场地（篮球场、活动室、会议室等）
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `life_venue` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `venue_name`    VARCHAR(128)      NOT NULL                COMMENT '场馆名称',
  `venue_type`    VARCHAR(64)       DEFAULT NULL            COMMENT '场馆类型（体育场地/活动室/会议室/党群服务中心等）',
  `cover_img`     VARCHAR(512)      DEFAULT NULL            COMMENT '封面图',
  `address`       VARCHAR(255)      DEFAULT NULL            COMMENT '地址',
  `capacity`      INT               DEFAULT NULL            COMMENT '容纳人数',
  `description`   TEXT              DEFAULT NULL            COMMENT '场馆介绍',
  `open_time`     VARCHAR(128)      DEFAULT NULL            COMMENT '开放时间说明（如 周一至周日 08:00-22:00）',
  `advance_days`  INT               NOT NULL DEFAULT 7      COMMENT '最多提前预约天数',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=开放预约 0=暂停预约 2=维护中',
  `manager_id`    BIGINT            DEFAULT NULL            COMMENT '场馆负责人用户ID（关联 sys_user.user_id）',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_type_status` (`tenant_id`, `venue_type`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='场馆资源表';

-- -------------------------------------------------------------
-- 场馆时段配置表
-- 说明：按日期+时段配置可预约数量（如每日多个时段）
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `life_venue_schedule` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `venue_id`      BIGINT            NOT NULL                COMMENT '场馆ID（关联 life_venue.id）',
  `schedule_date` DATE              NOT NULL                COMMENT '日期',
  `slot_start`    TIME              NOT NULL                COMMENT '时段开始时间',
  `slot_end`      TIME              NOT NULL                COMMENT '时段结束时间',
  `max_booking`   INT               NOT NULL DEFAULT 1      COMMENT '该时段最大预约数',
  `booked_count`  INT               NOT NULL DEFAULT 0      COMMENT '已预约数（冗余，避免 count 查询）',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=可预约 0=已关闭',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_venue_date_slot` (`venue_id`, `schedule_date`, `slot_start`),
  KEY `idx_tenant_date` (`tenant_id`, `schedule_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='场馆时段配置表';

-- -------------------------------------------------------------
-- 场馆预约记录表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `life_venue_booking` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `venue_id`      BIGINT            NOT NULL                COMMENT '场馆ID（关联 life_venue.id）',
  `schedule_id`   BIGINT            NOT NULL                COMMENT '时段配置ID（关联 life_venue_schedule.id）',
  `user_id`       BIGINT            NOT NULL                COMMENT '预约用户ID（关联 sys_user.user_id）',
  `resident_id`   BIGINT            DEFAULT NULL            COMMENT '居民档案ID（关联 cm_resident.id）',
  `booking_date`  DATE              NOT NULL                COMMENT '预约日期',
  `slot_start`    TIME              NOT NULL                COMMENT '时段开始',
  `slot_end`      TIME              NOT NULL                COMMENT '时段结束',
  `contact_name`  VARCHAR(64)       NOT NULL                COMMENT '联系人',
  `contact_phone` VARCHAR(20)       NOT NULL                COMMENT '联系电话',
  `use_purpose`   VARCHAR(255)      DEFAULT NULL            COMMENT '使用目的',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=待审核 1=已通过 2=已拒绝 3=已取消 4=已使用',
  `cancel_reason` VARCHAR(255)      DEFAULT NULL            COMMENT '取消/拒绝原因',
  `checkin_at`    DATETIME          DEFAULT NULL            COMMENT '实际签到时间',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '预约时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_venue_date_status` (`venue_id`, `booking_date`, `status`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_tenant_status_created` (`tenant_id`, `status`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='场馆预约记录表';

SET FOREIGN_KEY_CHECKS = 1;
