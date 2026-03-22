# 金星北路社区智慧服务平台 — MySQL 建表脚本

## 说明

本目录下的 SQL 文件面向 **MySQL 8.0**，字符集 `utf8mb4`，存储引擎 `InnoDB`。  
后端基础框架为 [go-admin](https://github.com/wufujiegmail/go-admin)，系统级表（`sys_user`、`sys_role`、`sys_dept`、`sys_menu`、`sys_api`、`sys_dict_type`、`sys_dict_data`、`sys_opera_log`、`sys_login_log`、`sys_post`、`casbin_rule`）由 go-admin 自带迁移创建，本脚本**不重复创建**上述系统表，仅创建业务表。

## 执行顺序

按文件名数字前缀顺序依次执行：

| 文件 | 模块 |
|------|------|
| `01_tenant_base.sql`     | 租户基础扩展、文件资产、站内消息 |
| `02_resident_house.sql`  | 居民档案与房屋 |
| `03_gov_service.sql`     | 政务服务（政策法规、政务事项） |
| `04_community.sql`       | 社区公告与活动 |
| `05_volunteer.sql`       | 志愿服务与积分 |
| `06_housework.sql`       | 社区家政 |
| `07_life_circle.sql`     | 生活圈（电话黄页、商户、场馆） |
| `08_property.sql`        | 物业服务 |
| `09_health.sql`          | 健康管理 |
| `10_governance_travel.sql` | 协同善治与出行安全 |
| `11_neighbor.sql`        | 邻里互助 |
| `12_suggestion.sql`      | 建议直通车 |

## 快速执行

```bash
# 依次执行所有脚本（先确保已执行 go-admin 自带的 config/db-begin-mysql.sql 等）
for f in sql/0{1..9}_*.sql sql/1{0..2}_*.sql; do
  echo "==> $f"
  mysql -u root -p your_database < "$f"
done
```

## 设计约定

- **主键**：`BIGINT UNSIGNED AUTO_INCREMENT`
- **审计字段**：`created_at DATETIME`、`updated_at DATETIME`、`deleted_at DATETIME NULL`（软删，NULL 表示未删除）、`created_by BIGINT NULL`、`updated_by BIGINT NULL`
- **租户字段**：`tenant_id BIGINT NOT NULL`（系统公共表除外），所有列表查询默认追加 `WHERE tenant_id = ?`
- **金额**：`DECIMAL(12,2)`
- **长文本**：`TEXT`
- **枚举**：`TINYINT` + 字段注释说明语义
- **外键策略**：为避免影响高并发写入，**业务表不建物理 FK**，仅建普通索引并在注释中说明关联关系
- **联合索引**：高频列表场景补充 `(tenant_id, status, created_at)` 等联合索引
