-- =============================================================
-- 模块：志愿服务与积分
-- 说明：志愿项目、报名参与、积分账户、流水审核、兑换物资
-- 执行顺序：第 5 步
-- =============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------
-- 志愿服务项目表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `vol_project` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `project_name`  VARCHAR(255)      NOT NULL                COMMENT '项目名称',
  `cover_img`     VARCHAR(512)      DEFAULT NULL            COMMENT '封面图',
  `description`   LONGTEXT          DEFAULT NULL            COMMENT '项目介绍',
  `location`      VARCHAR(255)      DEFAULT NULL            COMMENT '活动地点',
  `start_time`    DATETIME          NOT NULL                COMMENT '开始时间',
  `end_time`      DATETIME          NOT NULL                COMMENT '结束时间',
  `max_volunteers` INT              DEFAULT NULL            COMMENT '最大招募人数，NULL 不限',
  `enroll_count`  INT               NOT NULL DEFAULT 0      COMMENT '已报名人数（冗余计数）',
  `point_reward`  DECIMAL(10,2)     NOT NULL DEFAULT 0      COMMENT '参与可获积分（允许小数）',
  `organizer_id`  BIGINT            DEFAULT NULL            COMMENT '发起人用户ID（关联 sys_user.user_id）',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=草稿 1=招募中 2=进行中 3=已结束 4=已取消',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_status_start` (`tenant_id`, `status`, `start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='志愿服务项目表';

-- -------------------------------------------------------------
-- 志愿报名/参与记录表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `vol_enroll` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `project_id`    BIGINT            NOT NULL                COMMENT '项目ID（关联 vol_project.id）',
  `user_id`       BIGINT            NOT NULL                COMMENT '志愿者用户ID（关联 sys_user.user_id）',
  `resident_id`   BIGINT            DEFAULT NULL            COMMENT '居民档案ID（关联 cm_resident.id）',
  `enroll_at`     DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '报名时间',
  `checkin_at`    DATETIME          DEFAULT NULL            COMMENT '签到时间',
  `checkout_at`   DATETIME          DEFAULT NULL            COMMENT '签退时间',
  `service_hours` DECIMAL(5,1)      DEFAULT NULL            COMMENT '实际服务时长（小时）',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=待审核 1=已通过 2=已拒绝 3=已签到 4=已完成 5=已取消',
  `point_issued`  TINYINT           NOT NULL DEFAULT 0      COMMENT '积分是否已发放：1=是 0=否',
  `remark`        VARCHAR(255)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_project_status` (`project_id`, `status`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_tenant_created` (`tenant_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='志愿服务报名/参与记录表';

-- -------------------------------------------------------------
-- 积分规则表
-- 说明：公示社区志愿服务积分规则，支持运营配置
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `vol_point_rule` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `rule_name`     VARCHAR(128)      NOT NULL                COMMENT '规则名称',
  `biz_type`      VARCHAR(64)       NOT NULL                COMMENT '业务类型（如 vol_project/activity/manual 等）',
  `point_val`     DECIMAL(10,2)     NOT NULL                COMMENT '积分数值（正数=增加，负数=扣减）',
  `description`   VARCHAR(512)      DEFAULT NULL            COMMENT '规则说明',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=启用 0=停用',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_biz_status` (`tenant_id`, `biz_type`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分规则配置表';

-- -------------------------------------------------------------
-- 积分账户表
-- 说明：每位居民一个积分账户（记录累计/可用积分）
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `vol_point_account` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `user_id`       BIGINT            NOT NULL                COMMENT '用户ID（关联 sys_user.user_id）',
  `resident_id`   BIGINT            DEFAULT NULL            COMMENT '居民档案ID（关联 cm_resident.id）',
  `total_point`   DECIMAL(12,2)     NOT NULL DEFAULT 0      COMMENT '累计获得积分',
  `used_point`    DECIMAL(12,2)     NOT NULL DEFAULT 0      COMMENT '已使用积分',
  `frozen_point`  DECIMAL(12,2)     NOT NULL DEFAULT 0      COMMENT '冻结积分（兑换待确认中）',
  `balance`       DECIMAL(12,2)     NOT NULL DEFAULT 0      COMMENT '当前可用积分（total - used - frozen）',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_user` (`tenant_id`, `user_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分账户表（每位居民一条）';

-- -------------------------------------------------------------
-- 积分流水表
-- 说明：支持系统自动生成、个人录入（待后台核实）
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `vol_point_txn` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `account_id`    BIGINT            NOT NULL                COMMENT '积分账户ID（关联 vol_point_account.id）',
  `user_id`       BIGINT            NOT NULL                COMMENT '用户ID',
  `biz_type`      VARCHAR(64)       NOT NULL                COMMENT '业务类型（vol_project/activity/exchange/manual 等）',
  `biz_id`        BIGINT            DEFAULT NULL            COMMENT '关联业务ID',
  `change_type`   TINYINT           NOT NULL                COMMENT '变更类型：1=增加 2=扣减 3=冻结 4=解冻',
  `point_val`     DECIMAL(10,2)     NOT NULL                COMMENT '本次变更积分值（绝对值）',
  `balance_after` DECIMAL(12,2)     NOT NULL                COMMENT '变更后余额快照',
  `source`        TINYINT           NOT NULL DEFAULT 1      COMMENT '来源：1=系统自动 2=个人录入 3=管理员操作',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=已生效 0=待审核 2=已撤销',
  `remark`        VARCHAR(255)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_account_created` (`account_id`, `created_at`),
  KEY `idx_tenant_status` (`tenant_id`, `status`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分流水表（支持系统生成/个人录入/管理员操作）';

-- -------------------------------------------------------------
-- 积分审核记录表
-- 说明：对个人录入积分进行后台核实留痕
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `vol_point_audit` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `txn_id`        BIGINT            NOT NULL                COMMENT '积分流水ID（关联 vol_point_txn.id）',
  `auditor_id`    BIGINT            DEFAULT NULL            COMMENT '审核人用户ID（关联 sys_user.user_id）',
  `audit_result`  TINYINT           NOT NULL                COMMENT '审核结果：1=通过 2=驳回',
  `audit_remark`  VARCHAR(512)      DEFAULT NULL            COMMENT '审核意见',
  `audit_at`      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '审核时间',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_txn_id` (`txn_id`),
  KEY `idx_tenant_audit` (`tenant_id`, `audit_result`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分审核记录表';

-- -------------------------------------------------------------
-- 积分兑换物资表
-- 说明：社区负责管理的可兑换物资商品
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `vol_goods` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `goods_name`    VARCHAR(128)      NOT NULL                COMMENT '物资名称',
  `goods_img`     VARCHAR(512)      DEFAULT NULL            COMMENT '物资图片地址',
  `description`   TEXT              DEFAULT NULL            COMMENT '物资说明',
  `point_cost`    DECIMAL(10,2)     NOT NULL                COMMENT '所需积分',
  `stock`         INT               NOT NULL DEFAULT 0      COMMENT '库存数量',
  `exchange_limit` INT              DEFAULT NULL            COMMENT '每人兑换上限，NULL 表示不限',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=上架 0=下架',
  `sort`          INT               NOT NULL DEFAULT 0      COMMENT '排序',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_status` (`tenant_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分兑换物资表';

-- -------------------------------------------------------------
-- 积分兑换订单表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `vol_goods_order` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `goods_id`      BIGINT            NOT NULL                COMMENT '物资ID（关联 vol_goods.id）',
  `user_id`       BIGINT            NOT NULL                COMMENT '兑换用户ID（关联 sys_user.user_id）',
  `account_id`    BIGINT            NOT NULL                COMMENT '积分账户ID（关联 vol_point_account.id）',
  `quantity`      INT               NOT NULL DEFAULT 1      COMMENT '兑换数量',
  `point_cost`    DECIMAL(10,2)     NOT NULL                COMMENT '实际消耗积分',
  `pickup_name`   VARCHAR(64)       DEFAULT NULL            COMMENT '领取人姓名',
  `pickup_phone`  VARCHAR(20)       DEFAULT NULL            COMMENT '领取人电话',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=待发放 1=已发放 2=已取消',
  `pickup_at`     DATETIME          DEFAULT NULL            COMMENT '领取/发放时间',
  `remark`        VARCHAR(255)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_status_created` (`tenant_id`, `status`, `created_at`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_goods_id` (`goods_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分兑换订单表';

SET FOREIGN_KEY_CHECKS = 1;
