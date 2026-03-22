-- =============================================================
-- 模块：建议直通车（协商议事）
-- 说明：议事主题发起、参与人管理、居民建议诉求、
--       部门/骨干回复、状态流转留痕
-- 执行顺序：第 12 步
-- =============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------
-- 议事主题表
-- 说明：人大代表、政协委员、党代表可发起；骨干居民也可发起
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `sug_topic` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `topic_no`      VARCHAR(64)       NOT NULL                COMMENT '议事编号（唯一）',
  `title`         VARCHAR(255)      NOT NULL                COMMENT '议事主题标题',
  `description`   LONGTEXT          DEFAULT NULL            COMMENT '议题详细说明',
  `initiator_id`  BIGINT            NOT NULL                COMMENT '发起人用户ID（关联 sys_user.user_id）',
  `initiator_type` TINYINT          NOT NULL DEFAULT 1      COMMENT '发起人身份：1=人大代表 2=政协委员 3=党代表 4=骨干居民 5=普通居民',
  `category`      VARCHAR(64)       DEFAULT NULL            COMMENT '议题分类（社区治理/环境整治/民生服务/其他）',
  `deadline`      DATETIME          DEFAULT NULL            COMMENT '议事截止时间，NULL 表示长期',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=草稿 1=发起中/征集意见 2=审议中 3=已决议 4=执行中 5=已结案 6=已撤销',
  `result`        TEXT              DEFAULT NULL            COMMENT '最终决议/结果说明',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_topic_no` (`topic_no`),
  KEY `idx_tenant_status_created` (`tenant_id`, `status`, `created_at`),
  KEY `idx_initiator_id` (`initiator_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='议事主题表（协商议事发起）';

-- -------------------------------------------------------------
-- 议事参与人表
-- 说明：受邀参与人（代表、委员、骨干居民、相关职能部门等）
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `sug_topic_participant` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `topic_id`      BIGINT            NOT NULL                COMMENT '议事主题ID（关联 sug_topic.id）',
  `user_id`       BIGINT            NOT NULL                COMMENT '参与人用户ID（关联 sys_user.user_id）',
  `role`          TINYINT           NOT NULL DEFAULT 1      COMMENT '参与角色：1=普通参与人 2=主持人 3=记录员 4=协调人',
  `participant_type` TINYINT        NOT NULL DEFAULT 1      COMMENT '人员身份：1=人大代表 2=政协委员 3=党代表 4=骨干居民 5=工作人员 6=其他',
  `join_at`       DATETIME          DEFAULT NULL            COMMENT '参与时间',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=参与中 0=已退出',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_topic_user` (`topic_id`, `user_id`),
  KEY `idx_tenant_user` (`tenant_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='议事参与人表';

-- -------------------------------------------------------------
-- 居民建议诉求表
-- 说明：承接居民通过"建议直通车"提交的各类建议和诉求
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `sug_proposal` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `topic_id`      BIGINT            DEFAULT NULL            COMMENT '关联议事主题ID（关联 sug_topic.id），NULL 表示独立建议',
  `proposal_no`   VARCHAR(64)       NOT NULL                COMMENT '建议编号（唯一）',
  `user_id`       BIGINT            NOT NULL                COMMENT '提交用户ID（关联 sys_user.user_id）',
  `title`         VARCHAR(255)      NOT NULL                COMMENT '建议/诉求标题',
  `content`       TEXT              NOT NULL                COMMENT '内容详述',
  `attachment_urls` TEXT            DEFAULT NULL            COMMENT '附件地址（JSON 数组）',
  `is_anonymous`  TINYINT           NOT NULL DEFAULT 0      COMMENT '是否匿名：1=是 0=否',
  `category`      VARCHAR(64)       DEFAULT NULL            COMMENT '分类（社区管理/环境/安全/公共设施/其他）',
  `assign_to`     BIGINT            DEFAULT NULL            COMMENT '责任人/承办人用户ID（关联 sys_user.user_id）',
  `expected_result` VARCHAR(512)    DEFAULT NULL            COMMENT '期望的结果描述',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=待受理 1=受理中 2=转办 3=处理中 4=已反馈 5=已结案 6=已驳回',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_proposal_no` (`proposal_no`),
  KEY `idx_tenant_status_created` (`tenant_id`, `status`, `created_at`),
  KEY `idx_topic_id` (`topic_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='居民建议诉求表';

-- -------------------------------------------------------------
-- 回复/办理反馈表
-- 说明：部门/工作人员对建议诉求的回复和处理进展反馈
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `sug_reply` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `proposal_id`   BIGINT            NOT NULL                COMMENT '建议ID（关联 sug_proposal.id）',
  `replier_id`    BIGINT            NOT NULL                COMMENT '回复人用户ID（关联 sys_user.user_id）',
  `reply_type`    TINYINT           NOT NULL DEFAULT 1      COMMENT '回复类型：1=受理确认 2=进展反馈 3=结案回复 4=转办通知',
  `content`       TEXT              NOT NULL                COMMENT '回复内容',
  `attachment_urls` TEXT            DEFAULT NULL            COMMENT '附件地址（JSON 数组）',
  `is_public`     TINYINT           NOT NULL DEFAULT 1      COMMENT '是否公开（居民可见）：1=是 0=否',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '回复时间',
  PRIMARY KEY (`id`),
  KEY `idx_proposal_id` (`proposal_id`),
  KEY `idx_tenant_created` (`tenant_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='建议诉求回复/办理反馈表';

-- -------------------------------------------------------------
-- 建议流转状态日志表
-- 说明：记录建议诉求每次状态变更的操作留痕（便于追溯）
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `sug_status_log` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `proposal_id`   BIGINT            NOT NULL                COMMENT '建议ID（关联 sug_proposal.id）',
  `from_status`   TINYINT           DEFAULT NULL            COMMENT '变更前状态',
  `to_status`     TINYINT           NOT NULL                COMMENT '变更后状态',
  `operator_id`   BIGINT            NOT NULL                COMMENT '操作人用户ID（关联 sys_user.user_id）',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注/原因',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`),
  KEY `idx_proposal_id` (`proposal_id`),
  KEY `idx_tenant_created` (`tenant_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='建议诉求状态流转日志';

SET FOREIGN_KEY_CHECKS = 1;
