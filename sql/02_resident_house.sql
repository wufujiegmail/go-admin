-- =============================================================
-- 模块：居民档案与房屋
-- 说明：管理居民基本信息、户/家庭、楼栋房屋及关联关系
-- 执行顺序：第 2 步
-- =============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------
-- 居民档案表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `cm_resident` (
  `id`              BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`       BIGINT            NOT NULL                COMMENT '租户ID',
  `user_id`         BIGINT            DEFAULT NULL            COMMENT '关联系统用户ID（sys_user.user_id），若已注册',
  `real_name`       VARCHAR(64)       NOT NULL                COMMENT '真实姓名',
  `id_card_masked`  VARCHAR(32)       DEFAULT NULL            COMMENT '身份证号（脱敏存储，如 310***1234）',
  `phone`           VARCHAR(20)       DEFAULT NULL            COMMENT '手机号',
  `gender`          TINYINT           NOT NULL DEFAULT 0      COMMENT '性别：0=未知 1=男 2=女',
  `birthday`        DATE              DEFAULT NULL            COMMENT '出生日期',
  `avatar`          VARCHAR(512)      DEFAULT NULL            COMMENT '头像地址',
  `nation`          VARCHAR(32)       DEFAULT NULL            COMMENT '民族',
  `education`       VARCHAR(32)       DEFAULT NULL            COMMENT '学历',
  `political_status` VARCHAR(32)      DEFAULT NULL            COMMENT '政治面貌（群众/党员/团员等）',
  `resident_type`   TINYINT           NOT NULL DEFAULT 1      COMMENT '居民类型：1=常住居民 2=流动居民 3=空挂户',
  `status`          TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=正常 0=注销',
  `remark`          VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`      BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`      BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`      DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_status` (`tenant_id`, `status`),
  KEY `idx_tenant_phone` (`tenant_id`, `phone`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='居民档案表';

-- -------------------------------------------------------------
-- 户/家庭表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `cm_household` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `household_no`  VARCHAR(64)       DEFAULT NULL            COMMENT '户号/家庭编号',
  `household_name` VARCHAR(128)     DEFAULT NULL            COMMENT '户主姓名（冗余显示用）',
  `head_resident_id` BIGINT         DEFAULT NULL            COMMENT '户主居民ID（关联 cm_resident.id）',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_id` (`tenant_id`),
  KEY `idx_head_resident` (`head_resident_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='户/家庭表';

-- -------------------------------------------------------------
-- 房屋/楼栋单元门牌表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `cm_house` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `building_no`   VARCHAR(32)       NOT NULL                COMMENT '楼栋号（如 1栋、A栋）',
  `unit_no`       VARCHAR(32)       DEFAULT NULL            COMMENT '单元号（如 1单元）',
  `floor_no`      VARCHAR(16)       DEFAULT NULL            COMMENT '楼层号',
  `room_no`       VARCHAR(32)       NOT NULL                COMMENT '门牌号（如 101）',
  `full_address`  VARCHAR(255)      DEFAULT NULL            COMMENT '完整地址（冗余，便于展示）',
  `area`          DECIMAL(8,2)      DEFAULT NULL            COMMENT '建筑面积（㎡）',
  `house_type`    TINYINT           NOT NULL DEFAULT 1      COMMENT '房屋类型：1=住宅 2=商铺 3=车位 4=其他',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=正常使用 2=空置 3=拆迁',
  `remark`        VARCHAR(512)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_building` (`tenant_id`, `building_no`, `unit_no`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='房屋/楼栋单元门牌表';

-- -------------------------------------------------------------
-- 居民-房屋关联关系表
-- 说明：同一居民可关联多套房屋；同一房屋可有多位关联居民
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `cm_resident_house_rel` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `resident_id`   BIGINT            NOT NULL                COMMENT '居民ID（关联 cm_resident.id）',
  `house_id`      BIGINT            NOT NULL                COMMENT '房屋ID（关联 cm_house.id）',
  `household_id`  BIGINT            DEFAULT NULL            COMMENT '所属户/家庭ID（关联 cm_household.id）',
  `rel_type`      TINYINT           NOT NULL DEFAULT 1      COMMENT '关系类型：1=业主 2=租户 3=家属 4=其他',
  `move_in_date`  DATE              DEFAULT NULL            COMMENT '入住/迁入日期',
  `move_out_date` DATE              DEFAULT NULL            COMMENT '迁出日期，NULL 表示仍居住',
  `is_primary`    TINYINT           NOT NULL DEFAULT 0      COMMENT '是否主要居住地：1=是 0=否',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_resident_id` (`resident_id`),
  KEY `idx_house_id` (`house_id`),
  KEY `idx_tenant_rel` (`tenant_id`, `rel_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='居民-房屋关联关系表（不建物理外键，依靠索引关联）';

-- -------------------------------------------------------------
-- 标签定义表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `cm_tag` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `tag_name`      VARCHAR(64)       NOT NULL                COMMENT '标签名称',
  `tag_type`      VARCHAR(64)       DEFAULT NULL            COMMENT '标签类型（如 resident_group、health 等）',
  `color`         VARCHAR(32)       DEFAULT NULL            COMMENT '展示颜色（十六进制，如 #FF6600）',
  `sort`          INT               NOT NULL DEFAULT 0      COMMENT '排序',
  `status`        TINYINT           NOT NULL DEFAULT 1      COMMENT '状态：1=启用 0=停用',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_type` (`tenant_id`, `tag_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='标签定义表（居民、公告等通用标签）';

-- -------------------------------------------------------------
-- 居民标签关联表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `cm_resident_tag_rel` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `resident_id`   BIGINT            NOT NULL                COMMENT '居民ID（关联 cm_resident.id）',
  `tag_id`        BIGINT            NOT NULL                COMMENT '标签ID（关联 cm_tag.id）',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_resident_tag` (`resident_id`, `tag_id`),
  KEY `idx_tenant_tag` (`tenant_id`, `tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='居民标签关联表';

-- -------------------------------------------------------------
-- 紧急联系人表
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `cm_emergency_contact` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id`     BIGINT            NOT NULL                COMMENT '租户ID',
  `resident_id`   BIGINT            NOT NULL                COMMENT '居民ID（关联 cm_resident.id）',
  `contact_name`  VARCHAR(64)       NOT NULL                COMMENT '联系人姓名',
  `relationship`  VARCHAR(32)       DEFAULT NULL            COMMENT '与居民关系（配偶/子女/父母等）',
  `phone`         VARCHAR(20)       NOT NULL                COMMENT '联系电话',
  `sort`          INT               NOT NULL DEFAULT 0      COMMENT '排序（紧急程度）',
  `remark`        VARCHAR(255)      DEFAULT NULL            COMMENT '备注',
  `created_by`    BIGINT            DEFAULT NULL            COMMENT '创建人',
  `updated_by`    BIGINT            DEFAULT NULL            COMMENT '更新人',
  `created_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at`    DATETIME          DEFAULT NULL            COMMENT '软删时间',
  PRIMARY KEY (`id`),
  KEY `idx_resident_id` (`tenant_id`, `resident_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='紧急联系人表';

SET FOREIGN_KEY_CHECKS = 1;
