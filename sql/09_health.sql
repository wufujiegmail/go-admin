-- =============================================================
-- 模块：健康管理
-- 说明：健康档案、血压/血糖记录、健康咨询、紧急呼叫、
--       合作医院、挂号端口配置及跳转日志、医保查询日志
-- 执行顺序：第 9 步
-- =============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------
-- 居民健康档案表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `health_profile` (
  `id`              BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`       BIGINT            NOT NULL                COMMENT '租户ID',
  `user_id`         BIGINT            NOT NULL                COMMENT '用户ID（关联 sys_user.user_id）',
  `resident_id`     BIGINT            DEFAULT NULL            COMMENT '居民档案ID（关联 cm_resident.id）',
  `blood_type`      VARCHAR(8)        DEFAULT NULL            COMMENT '血型（A/B/AB/O/Rh+/Rh-）',
  `height`          DECIMAL(5,1)      DEFAULT NULL            COMMENT '身高（cm）',
  `weight`          DECIMAL(5,1)      DEFAULT NULL            COMMENT '体重（kg）',
  `allergies`       TEXT              DEFAULT NULL            COMMENT '过敏史说明',
  `chronic_diseases` TEXT             DEFAULT NULL            COMMENT '慢性病史说明',
  `medical_history` TEXT              DEFAULT NULL            COMMENT '重大病史说明',
  `disability_type` VARCHAR(64)       DEFAULT NULL            COMMENT '残疾类型（无/肢体/视力/听力/精神等）',
  `emergency_contact_id` BIGINT       DEFAULT NULL            COMMENT '紧急联系人ID（关联 cm_emergency_contact.id）',
  `created_by`      BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`      BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`      DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_user` (`tenant_id`, `user_id`),
  KEY `idx_resident_id` (`resident_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='居民健康档案表';

-- -------------------------------------------------------------
-- 血压记录表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `health_bp_record` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `user_id`       BIGINT            NOT NULL                COMMENT '用户ID（关联 sys_user.user_id）',
  `profile_id`    BIGINT            DEFAULT NULL            COMMENT '健康档案ID（关联 health_profile.id）',
  `systolic`      INT               NOT NULL                COMMENT '收缩压（mmHg，高压）',
  `diastolic`     INT               NOT NULL                COMMENT '舒张压（mmHg，低压）',
  `pulse`         INT               DEFAULT NULL            COMMENT '脉搏（次/分钟）',
  `measure_time`  DATETIME          NOT NULL                COMMENT '测量时间',
  `measure_scene` TINYINT           DEFAULT NULL            COMMENT '测量场景：1=晨起 2=运动后 3=睡前 4=其他',
  `device_type`   VARCHAR(64)       DEFAULT NULL            COMMENT '测量设备类型',
  `remark`        VARCHAR(255)      DEFAULT NULL            COMMENT '备注',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_measure` (`user_id`, `measure_time`),
  KEY `idx_tenant_created` (`tenant_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='血压记录表';

-- -------------------------------------------------------------
-- 血糖记录表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `health_glucose_record` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `user_id`       BIGINT            NOT NULL                COMMENT '用户ID（关联 sys_user.user_id）',
  `profile_id`    BIGINT            DEFAULT NULL            COMMENT '健康档案ID（关联 health_profile.id）',
  `glucose`       DECIMAL(5,2)      NOT NULL                COMMENT '血糖值（mmol/L）',
  `measure_time`  DATETIME          NOT NULL                COMMENT '测量时间',
  `measure_scene` TINYINT           DEFAULT NULL            COMMENT '测量场景：1=空腹 2=餐后1h 3=餐后2h 4=随机',
  `device_type`   VARCHAR(64)       DEFAULT NULL            COMMENT '测量设备',
  `remark`        VARCHAR(255)      DEFAULT NULL            COMMENT '备注',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_measure` (`user_id`, `measure_time`),
  KEY `idx_tenant_created` (`tenant_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='血糖记录表';

-- -------------------------------------------------------------
-- 健康咨询表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `health_consult` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `user_id`       BIGINT            NOT NULL                COMMENT '咨询用户ID（关联 sys_user.user_id）',
  `consult_type`  TINYINT           NOT NULL DEFAULT 1      COMMENT '咨询类型：1=图文咨询 2=健康评估',
  `title`         VARCHAR(255)      DEFAULT NULL            COMMENT '咨询主题',
  `content`       TEXT              NOT NULL                COMMENT '咨询内容',
  `reply`         TEXT              DEFAULT NULL            COMMENT '医生/专家回复',
  `replier_id`    BIGINT            DEFAULT NULL            COMMENT '回复人用户ID',
  `reply_at`      DATETIME          DEFAULT NULL            COMMENT '回复时间',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=待回复 1=已回复 2=已关闭',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_status` (`user_id`, `status`),
  KEY `idx_tenant_status_created` (`tenant_id`, `status`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='健康咨询表';

-- -------------------------------------------------------------
-- 紧急呼叫记录表
-- 说明：绑定紧急联系人，发送告警通知
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `health_emergency_call` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `user_id`       BIGINT            NOT NULL                COMMENT '呼叫用户ID（关联 sys_user.user_id）',
  `profile_id`    BIGINT            DEFAULT NULL            COMMENT '健康档案ID',
  `emergency_contact_id` BIGINT     DEFAULT NULL            COMMENT '紧急联系人ID（关联 cm_emergency_contact.id）',
  `location_desc` VARCHAR(255)      DEFAULT NULL            COMMENT '位置描述',
  `lng`           DECIMAL(11,7)     DEFAULT NULL            COMMENT '经度',
  `lat`           DECIMAL(11,7)     DEFAULT NULL            COMMENT '纬度',
  `call_at`       DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '呼叫时间',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '处理状态：0=未处理 1=处理中 2=已处置',
  `handle_remark` VARCHAR(512)      DEFAULT NULL            COMMENT '处置备注',
  `handle_at`     DATETIME          DEFAULT NULL            COMMENT '处置时间',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_call` (`user_id`, `call_at`),
  KEY `idx_tenant_status` (`tenant_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='紧急呼叫记录表';

-- -------------------------------------------------------------
-- 合作医院/卫生院表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `health_hospital` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `hosp_name`     VARCHAR(128)      NOT NULL                COMMENT '医院/卫生院名称',
  `hosp_type`     TINYINT           NOT NULL DEFAULT 1      COMMENT '类型：1=三级医院 2=二级医院 3=社区卫生院 4=专科医院',
  `logo`          VARCHAR(512)      DEFAULT NULL            COMMENT 'Logo 地址',
  `address`       VARCHAR(255)      DEFAULT NULL            COMMENT '地址',
  `phone`         VARCHAR(50)       DEFAULT NULL            COMMENT '联系电话',
  `description`   TEXT              DEFAULT NULL            COMMENT '简介',
  `is_partner`    TINYINT           NOT NULL DEFAULT 1      COMMENT '是否党建共建合作单位：1=是 0=否',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=上线 0=下线',
  `sort`          INT               NOT NULL DEFAULT 0      COMMENT '排序',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_status` (`tenant_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='合作医院/卫生院表';

-- -------------------------------------------------------------
-- 挂号端口配置表
-- 说明：接入合作医院/卫生院挂号系统
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `health_reg_channel` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `hospital_id`   BIGINT            NOT NULL                COMMENT '医院ID（关联 health_hospital.id）',
  `channel_name`  VARCHAR(128)      NOT NULL                COMMENT '挂号端口名称',
  `channel_url`   VARCHAR(1024)     NOT NULL                COMMENT '挂号跳转地址（H5/小程序 scheme）',
  `channel_type`  TINYINT           NOT NULL DEFAULT 1      COMMENT '端口类型：1=H5 2=微信小程序 3=API',
  `dept_name`     VARCHAR(64)       DEFAULT NULL            COMMENT '科室名称（NULL 表示通用入口）',
  `sort`          INT               NOT NULL DEFAULT 0      COMMENT '排序',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=启用 0=停用',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_hospital_status` (`hospital_id`, `status`),
  KEY `idx_tenant_status` (`tenant_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='挂号端口配置表';

-- -------------------------------------------------------------
-- 挂号跳转日志
-- 说明：记录居民挂号跳转行为
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `health_reg_log` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `user_id`       BIGINT            DEFAULT NULL            COMMENT '用户ID（关联 sys_user.user_id）',
  `channel_id`    BIGINT            NOT NULL                COMMENT '挂号端口ID（关联 health_reg_channel.id）',
  `hospital_id`   BIGINT            NOT NULL                COMMENT '医院ID',
  `client_ip`     VARCHAR(64)       DEFAULT NULL            COMMENT '客户端IP',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '跳转时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_channel` (`tenant_id`, `channel_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='挂号跳转日志（统计用途）';

-- -------------------------------------------------------------
-- 医保查询日志
-- 说明：记录居民医保查询行为（对接医疗系统端口）
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `health_insurance_query_log` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `user_id`       BIGINT            DEFAULT NULL            COMMENT '用户ID（关联 sys_user.user_id）',
  `query_type`    TINYINT           NOT NULL DEFAULT 1      COMMENT '查询类型：1=余额 2=明细 3=报销比例',
  `query_result`  TEXT              DEFAULT NULL            COMMENT '查询结果摘要（脱敏后存储）',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '查询状态：1=成功 0=失败',
  `error_msg`     VARCHAR(512)      DEFAULT NULL            COMMENT '失败原因',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '查询时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_user` (`tenant_id`, `user_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='医保查询日志';

SET FOREIGN_KEY_CHECKS = 1;
