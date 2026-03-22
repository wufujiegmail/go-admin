-- =============================================================
-- 模块：物业服务
-- 说明：物业公司档案、物业费账单/缴费、资源回收、
--       装修报备、房屋出租出售登记、公共设施报修
-- 执行顺序：第 8 步
-- =============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------
-- 物业公司/物业服务主体表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `prop_property_org` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `org_name`      VARCHAR(128)      NOT NULL                COMMENT '物业公司/机构名称',
  `logo`          VARCHAR(512)      DEFAULT NULL            COMMENT 'Logo 地址',
  `contact_name`  VARCHAR(64)       DEFAULT NULL            COMMENT '联系人',
  `contact_phone` VARCHAR(20)       DEFAULT NULL            COMMENT '联系电话',
  `address`       VARCHAR(255)      DEFAULT NULL            COMMENT '办公地址',
  `service_scope` TEXT              DEFAULT NULL            COMMENT '服务范围说明',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=正常 0=停用',
  `user_id`       BIGINT            DEFAULT NULL            COMMENT '关联物业账号用户ID（sys_user.user_id）',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_status` (`tenant_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='物业公司/服务主体表';

-- -------------------------------------------------------------
-- 物业费账单表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `prop_fee_bill` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `property_org_id` BIGINT          NOT NULL                COMMENT '物业公司ID（关联 prop_property_org.id）',
  `house_id`      BIGINT            NOT NULL                COMMENT '房屋ID（关联 cm_house.id）',
  `bill_no`       VARCHAR(64)       NOT NULL                COMMENT '账单编号（唯一）',
  `fee_type`      TINYINT           NOT NULL DEFAULT 1      COMMENT '费用类型：1=物业管理费 2=停车费 3=水费 4=电费 5=其他',
  `fee_name`      VARCHAR(64)       NOT NULL                COMMENT '费用名称',
  `bill_period`   VARCHAR(16)       NOT NULL                COMMENT '账单周期（如 2024-01）',
  `amount`        DECIMAL(12,2)     NOT NULL                COMMENT '应缴金额（元）',
  `due_date`      DATE              NOT NULL                COMMENT '缴费截止日期',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=待缴费 1=已缴费 2=已逾期 3=已减免',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_bill_no` (`bill_no`),
  KEY `idx_house_period` (`house_id`, `bill_period`),
  KEY `idx_tenant_status_due` (`tenant_id`, `status`, `due_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='物业费账单表';

-- -------------------------------------------------------------
-- 物业费缴费记录表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `prop_fee_payment` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `bill_id`       BIGINT            NOT NULL                COMMENT '账单ID（关联 prop_fee_bill.id）',
  `user_id`       BIGINT            NOT NULL                COMMENT '缴费用户ID（关联 sys_user.user_id）',
  `pay_amount`    DECIMAL(12,2)     NOT NULL                COMMENT '实缴金额（元）',
  `pay_channel`   TINYINT           NOT NULL DEFAULT 1      COMMENT '缴费渠道：1=微信支付 2=现金 3=转账 4=其他',
  `trade_no`      VARCHAR(128)      DEFAULT NULL            COMMENT '第三方交易流水号',
  `pay_at`        DATETIME          NOT NULL                COMMENT '缴费时间',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '缴费状态：1=成功 2=退款中 3=已退款',
  `remark`        VARCHAR(255)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_bill_id` (`bill_id`),
  KEY `idx_tenant_user` (`tenant_id`, `user_id`),
  KEY `idx_pay_at` (`pay_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='物业费缴费记录表';

-- -------------------------------------------------------------
-- 资源回收订单表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `prop_recycle_order` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `order_no`      VARCHAR(64)       NOT NULL                COMMENT '工单编号',
  `user_id`       BIGINT            NOT NULL                COMMENT '下单用户ID（关联 sys_user.user_id）',
  `contact_name`  VARCHAR(64)       NOT NULL                COMMENT '联系人',
  `contact_phone` VARCHAR(20)       NOT NULL                COMMENT '联系电话',
  `address`       VARCHAR(255)      NOT NULL                COMMENT '回收地址',
  `appoint_time`  DATETIME          NOT NULL                COMMENT '预约上门时间',
  `recycle_type`  VARCHAR(128)      DEFAULT NULL            COMMENT '回收物品类型说明',
  `estimate_weight` DECIMAL(8,2)    DEFAULT NULL            COMMENT '预估重量（kg）',
  `actual_weight` DECIMAL(8,2)      DEFAULT NULL            COMMENT '实际重量（kg）',
  `amount`        DECIMAL(10,2)     DEFAULT NULL            COMMENT '回收金额（元）',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=待接单 1=已接单 2=已上门 3=已完成 4=已取消',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_tenant_status_created` (`tenant_id`, `status`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资源回收订单表';

-- -------------------------------------------------------------
-- 装修报备表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `prop_renovation_filing` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `house_id`      BIGINT            NOT NULL                COMMENT '房屋ID（关联 cm_house.id）',
  `user_id`       BIGINT            NOT NULL                COMMENT '报备用户ID（关联 sys_user.user_id）',
  `owner_name`    VARCHAR(64)       NOT NULL                COMMENT '业主姓名',
  `owner_phone`   VARCHAR(20)       NOT NULL                COMMENT '业主电话',
  `contractor`    VARCHAR(128)      DEFAULT NULL            COMMENT '施工单位/装修公司',
  `plan_start`    DATE              NOT NULL                COMMENT '计划开工日期',
  `plan_end`      DATE              NOT NULL                COMMENT '计划竣工日期',
  `description`   TEXT              DEFAULT NULL            COMMENT '装修内容描述',
  `deposit`       DECIMAL(10,2)     DEFAULT NULL            COMMENT '装修押金（元）',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=待审核 1=已通过 2=已驳回 3=施工中 4=已完工',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '审核备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_house_id` (`house_id`),
  KEY `idx_tenant_status` (`tenant_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='装修报备表';

-- -------------------------------------------------------------
-- 房屋出租/出售登记表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `prop_house_trade_filing` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `house_id`      BIGINT            NOT NULL                COMMENT '房屋ID（关联 cm_house.id）',
  `user_id`       BIGINT            NOT NULL                COMMENT '登记用户ID（关联 sys_user.user_id）',
  `trade_type`    TINYINT           NOT NULL                COMMENT '交易类型：1=出租 2=出售',
  `price`         DECIMAL(12,2)     DEFAULT NULL            COMMENT '租金/售价（元）',
  `price_unit`    VARCHAR(16)       DEFAULT NULL            COMMENT '价格单位（如 元/月、万元）',
  `contact_name`  VARCHAR(64)       NOT NULL                COMMENT '联系人',
  `contact_phone` VARCHAR(20)       NOT NULL                COMMENT '联系电话',
  `description`   TEXT              DEFAULT NULL            COMMENT '房源描述',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=在售/在租 2=已成交 3=已下架',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_house_type` (`house_id`, `trade_type`),
  KEY `idx_tenant_type_status` (`tenant_id`, `trade_type`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='房屋出租/出售登记表';

-- -------------------------------------------------------------
-- 公共设施报修工单表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `prop_repair_order` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `order_no`      VARCHAR(64)       NOT NULL                COMMENT '报修编号',
  `property_org_id` BIGINT          DEFAULT NULL            COMMENT '受理物业公司ID（关联 prop_property_org.id）',
  `reporter_id`   BIGINT            NOT NULL                COMMENT '报修人用户ID（关联 sys_user.user_id）',
  `contact_name`  VARCHAR(64)       NOT NULL                COMMENT '联系人',
  `contact_phone` VARCHAR(20)       NOT NULL                COMMENT '联系电话',
  `location`      VARCHAR(255)      NOT NULL                COMMENT '故障位置',
  `repair_type`   VARCHAR(64)       DEFAULT NULL            COMMENT '报修类型（路灯/电梯/管道/其他）',
  `description`   TEXT              DEFAULT NULL            COMMENT '故障描述',
  `img_urls`      TEXT              DEFAULT NULL            COMMENT '现场照片（JSON 数组）',
  `priority`      TINYINT           NOT NULL DEFAULT 2      COMMENT '优先级：1=紧急 2=普通 3=低',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=待受理 1=处理中 2=已完成 3=已取消',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '报修时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_tenant_status_created` (`tenant_id`, `status`, `created_at`),
  KEY `idx_property_org` (`property_org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='公共设施报修工单表';

-- -------------------------------------------------------------
-- 报修处理过程记录表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `prop_repair_process` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `order_id`      BIGINT            NOT NULL                COMMENT '报修工单ID（关联 prop_repair_order.id）',
  `handler_id`    BIGINT            DEFAULT NULL            COMMENT '处理人用户ID（关联 sys_user.user_id）',
  `action`        VARCHAR(64)       NOT NULL                COMMENT '处理动作（受理/派工/上门/完工/验收等）',
  `content`       TEXT              DEFAULT NULL            COMMENT '处理说明',
  `img_urls`      TEXT              DEFAULT NULL            COMMENT '处理照片（JSON 数组）',
  `from_status`   TINYINT           DEFAULT NULL            COMMENT '变更前状态',
  `to_status`     TINYINT           NOT NULL                COMMENT '变更后状态',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_tenant_created` (`tenant_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='报修工单处理过程记录表';

SET FOREIGN_KEY_CHECKS = 1;
