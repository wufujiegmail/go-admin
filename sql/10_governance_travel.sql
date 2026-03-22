-- =============================================================
-- 模块：协同善治与出行安全
-- 说明：法律/心理咨询、矛盾纠纷调解、公交查询、
--       挪车服务、智能安防告警
-- 执行顺序：第 10 步
-- =============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------
-- 咨询工单表（法律咨询 / 心理咨询）
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `gov_consult_order` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `order_no`      VARCHAR(64)       NOT NULL                COMMENT '工单编号',
  `consult_type`  TINYINT           NOT NULL                COMMENT '咨询类型：1=法律咨询 2=心理咨询',
  `user_id`       BIGINT            NOT NULL                COMMENT '咨询用户ID（关联 sys_user.user_id）',
  `title`         VARCHAR(255)      NOT NULL                COMMENT '咨询标题/主题',
  `content`       TEXT              NOT NULL                COMMENT '咨询内容',
  `is_anonymous`  TINYINT           NOT NULL DEFAULT 0      COMMENT '是否匿名：1=是 0=否',
  `consultant_id` BIGINT            DEFAULT NULL            COMMENT '接单顾问用户ID（关联 sys_user.user_id）',
  `reply`         TEXT              DEFAULT NULL            COMMENT '顾问回复',
  `reply_at`      DATETIME          DEFAULT NULL            COMMENT '回复时间',
  `appoint_time`  DATETIME          DEFAULT NULL            COMMENT '预约面谈时间（如需线下）',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=待受理 1=处理中 2=已回复 3=已关闭',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_tenant_type_status` (`tenant_id`, `consult_type`, `status`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='法律/心理咨询工单表';

-- -------------------------------------------------------------
-- 矛盾纠纷调解案件表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `gov_mediation_case` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `case_no`       VARCHAR(64)       NOT NULL                COMMENT '案件编号',
  `case_type`     VARCHAR(64)       DEFAULT NULL            COMMENT '纠纷类型（邻里/劳务/家庭/物业/其他）',
  `applicant_id`  BIGINT            NOT NULL                COMMENT '申请人用户ID（关联 sys_user.user_id）',
  `respondent_info` VARCHAR(255)    DEFAULT NULL            COMMENT '被申请方信息（姓名/联系方式）',
  `title`         VARCHAR(255)      NOT NULL                COMMENT '案件标题',
  `description`   TEXT              NOT NULL                COMMENT '纠纷描述',
  `evidence_urls` TEXT              DEFAULT NULL            COMMENT '证据材料地址（JSON 数组）',
  `mediator_id`   BIGINT            DEFAULT NULL            COMMENT '调解员用户ID（关联 sys_user.user_id）',
  `mediate_time`  DATETIME          DEFAULT NULL            COMMENT '调解时间',
  `mediate_place` VARCHAR(255)      DEFAULT NULL            COMMENT '调解地点',
  `outcome`       TEXT              DEFAULT NULL            COMMENT '调解结果说明',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=待受理 1=受理中 2=调解中 3=已调解 4=未调解结案 5=已撤销',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_case_no` (`case_no`),
  KEY `idx_tenant_status_created` (`tenant_id`, `status`, `created_at`),
  KEY `idx_applicant_id` (`applicant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='矛盾纠纷调解案件表';

-- -------------------------------------------------------------
-- 公交线路缓存表
-- 说明：接入公交管理端口，本地缓存线路基础信息
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `travel_bus_line` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `line_no`       VARCHAR(32)       NOT NULL                COMMENT '线路编号（如 25路）',
  `line_name`     VARCHAR(128)      NOT NULL                COMMENT '线路名称',
  `direction`     TINYINT           NOT NULL DEFAULT 1      COMMENT '方向：1=上行 2=下行',
  `start_station` VARCHAR(64)       DEFAULT NULL            COMMENT '起始站',
  `end_station`   VARCHAR(64)       DEFAULT NULL            COMMENT '终点站',
  `first_time`    TIME              DEFAULT NULL            COMMENT '首班时间',
  `last_time`     TIME              DEFAULT NULL            COMMENT '末班时间',
  `interval_min`  INT               DEFAULT NULL            COMMENT '发车间隔（分钟）',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=运营 0=停运',
  `synced_at`     DATETIME          DEFAULT NULL            COMMENT '最后同步时间（来自公交端口）',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_line` (`tenant_id`, `line_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='公交线路缓存表';

-- -------------------------------------------------------------
-- 公交站点缓存表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `travel_bus_stop` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `line_id`       BIGINT            NOT NULL                COMMENT '线路ID（关联 travel_bus_line.id）',
  `stop_name`     VARCHAR(64)       NOT NULL                COMMENT '站点名称',
  `stop_order`    INT               NOT NULL                COMMENT '站序',
  `lng`           DECIMAL(11,7)     DEFAULT NULL            COMMENT '经度',
  `lat`           DECIMAL(11,7)     DEFAULT NULL            COMMENT '纬度',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_line_order` (`line_id`, `stop_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='公交站点缓存表';

-- -------------------------------------------------------------
-- 公交实时查询日志
-- 说明：记录居民查询公交到站时间的行为日志（统计用途）
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `travel_bus_realtime_log` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `user_id`       BIGINT            DEFAULT NULL            COMMENT '查询用户ID',
  `line_id`       BIGINT            DEFAULT NULL            COMMENT '线路ID',
  `stop_id`       BIGINT            DEFAULT NULL            COMMENT '查询站点ID',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '查询时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_line` (`tenant_id`, `line_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='公交实时查询日志';

-- -------------------------------------------------------------
-- 挪车请求表
-- 说明：居民发起挪车需求，通过小区车主信息联系
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `travel_move_car_request` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `requester_id`  BIGINT            NOT NULL                COMMENT '请求人用户ID（关联 sys_user.user_id）',
  `plate_no`      VARCHAR(16)       NOT NULL                COMMENT '需要挪动的车牌号',
  `location_desc` VARCHAR(255)      NOT NULL                COMMENT '车辆位置描述',
  `img_url`       VARCHAR(512)      DEFAULT NULL            COMMENT '现场照片',
  `contact_phone` VARCHAR(20)       DEFAULT NULL            COMMENT '联系电话（如需回拨）',
  `notify_channel` TINYINT          NOT NULL DEFAULT 1      COMMENT '通知方式：1=平台消息 2=电话 3=短信',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '状态：0=待处理 1=已通知 2=已挪车 3=超时关闭',
  `remark`        VARCHAR(255)      DEFAULT NULL            COMMENT '备注',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_status_created` (`tenant_id`, `status`, `created_at`),
  KEY `idx_plate_no` (`plate_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='挪车请求表';

-- -------------------------------------------------------------
-- 安防设备表
-- 说明：记录智能安防设备（如防溺水监测摄像头等）信息
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `travel_security_device` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `device_no`     VARCHAR(64)       NOT NULL                COMMENT '设备编号（唯一）',
  `device_name`   VARCHAR(128)      NOT NULL                COMMENT '设备名称',
  `device_type`   VARCHAR(64)       NOT NULL                COMMENT '设备类型（防溺水/人脸识别/门禁/监控等）',
  `location_desc` VARCHAR(255)      DEFAULT NULL            COMMENT '安装位置描述',
  `lng`           DECIMAL(11,7)     DEFAULT NULL            COMMENT '经度',
  `lat`           DECIMAL(11,7)     DEFAULT NULL            COMMENT '纬度',
  `online_status` TINYINT           NOT NULL DEFAULT 0      COMMENT '在线状态：1=在线 0=离线',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '设备状态：1=正常 0=故障 2=维修中',
  `last_heartbeat` DATETIME         DEFAULT NULL            COMMENT '最后心跳时间',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_device_no` (`device_no`),
  KEY `idx_tenant_type_status` (`tenant_id`, `device_type`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='智能安防设备表';

-- -------------------------------------------------------------
-- 安防告警事件表
-- 说明：设备触发告警（如防溺水人员落水告警）
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `travel_security_alert` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `device_id`     BIGINT            NOT NULL                COMMENT '设备ID（关联 travel_security_device.id）',
  `alert_type`    VARCHAR(64)       NOT NULL                COMMENT '告警类型（drowning=防溺水/intrusion=入侵/other）',
  `alert_level`   TINYINT           NOT NULL DEFAULT 2      COMMENT '告警级别：1=紧急 2=重要 3=一般',
  `description`   VARCHAR(512)      DEFAULT NULL            COMMENT '告警描述',
  `img_url`       VARCHAR(512)      DEFAULT NULL            COMMENT '告警截图地址',
  `video_url`     VARCHAR(512)      DEFAULT NULL            COMMENT '告警录像地址',
  `lng`           DECIMAL(11,7)     DEFAULT NULL            COMMENT '经度',
  `lat`           DECIMAL(11,7)     DEFAULT NULL            COMMENT '纬度',
  `alert_at`      DATETIME          NOT NULL                COMMENT '告警发生时间',
  `status`        TINYINT           NOT NULL DEFAULT 0      COMMENT '处理状态：0=待处理 1=处理中 2=已处置 3=误报',
  `handler_id`    BIGINT            DEFAULT NULL            COMMENT '处置人用户ID',
  `handle_remark` VARCHAR(512)      DEFAULT NULL            COMMENT '处置说明',
  `handle_at`     DATETIME          DEFAULT NULL            COMMENT '处置时间',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_device_alert` (`device_id`, `alert_at`),
  KEY `idx_tenant_level_status` (`tenant_id`, `alert_level`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='安防告警事件表';

SET FOREIGN_KEY_CHECKS = 1;
