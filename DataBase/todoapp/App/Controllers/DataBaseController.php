<?php
namespace App\Controllers;

use PDO;
use PDOException;
use App\Database\QueryBuilder;
use App\Traits\ResponseTrait;
use App\Validations\ValidateData;

class DataBaseController {
    use ResponseTrait;
    use ValidateData;

    protected $queryBuilder;

    public function __construct() {
        $this->queryBuilder = new QueryBuilder();
    }

    public function createTable($request)
    {
        error_log("CreateTable method called");

        try {
            // اعتبارسنجی داده‌های ورودی
            if (!$this->validateCreateTableRequest($request)) {
                return $this->jsonMsg(false, "Invalid request data", HTTP_BadREQUEST);
            }

            // پاکسازی و اعتبارسنجی نام جدول
            $tableName = $this->sanitizeTableName($request->table_name);
            if (!$tableName) {
                return $this->jsonMsg(false, "Invalid table name", HTTP_BadREQUEST);
            }

            // ساخت تعاریف ستون‌ها
            $columnDefinitions = $this->buildColumnDefinitions($request->columns);
            if (empty($columnDefinitions)) {
                return $this->jsonMsg(false, "No valid columns defined", HTTP_BadREQUEST);
            }

            // ساخت کوئری SQL
            $sql = "CREATE TABLE IF NOT EXISTS `{$tableName}` (";
            $sql .= implode(', ', $columnDefinitions);
            $sql .= ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";

            error_log("SQL Query: " . $sql);

            // اجرای کوئری
            $statement = $this->queryBuilder->getPdo()->prepare($sql);
            $result = $statement->execute();

            if ($result) {
                // بررسی وجود جدول
                $checkTable = $this->queryBuilder->getPdo()->query("SHOW TABLES LIKE '{$tableName}'");
                if ($checkTable->rowCount() > 0) {
                    return $this->jsonMsg(true, "Table created/updated successfully", HTTP_OK, [
                        'table_name' => $tableName,
                        'columns' => $request->columns,
                        'sql' => $sql
                    ]);
                }
            }

            $error = $statement->errorInfo();
            return $this->jsonMsg(false, "Failed to create table: " . $error[2], HTTP_BadREQUEST);

        } catch (\Exception $e) {
            error_log("Exception caught: " . $e->getMessage());
            return $this->jsonMsg(false, "Error: " . $e->getMessage(), HTTP_BadREQUEST);
        }
    }

    /**
     * اعتبارسنجی درخواست ایجاد جدول
     */
    private function validateCreateTableRequest($request): bool
    {
        return isset($request->table_name)
            && isset($request->columns)
            && is_object($request->columns)
            && count((array)$request->columns) > 0;
    }

    /**
     * پاکسازی و اعتبارسنجی نام جدول
     */
    private function sanitizeTableName(string $tableName): ?string
    {
        $tableName = preg_replace('/[^a-zA-Z0-9_]/', '', $tableName);
        return !empty($tableName) ? strtolower($tableName) : null;
    }

    /**
     * ساخت تعاریف ستون‌ها
     */
    private function buildColumnDefinitions(object $columns): array
    {
        $validTypes = [
            'INT', 'TINYINT', 'SMALLINT', 'MEDIUMINT', 'BIGINT',
            'DECIMAL', 'FLOAT', 'DOUBLE',
            'CHAR', 'VARCHAR', 'TEXT', 'TINYTEXT', 'MEDIUMTEXT', 'LONGTEXT',
            'DATE', 'DATETIME', 'TIMESTAMP', 'TIME', 'YEAR',
            'ENUM', 'SET',
            'BOOLEAN', 'BOOL'
        ];

        $columnDefinitions = [];

        foreach ($columns as $name => $definition) {
            // پاکسازی نام ستون
            $name = preg_replace('/[^a-zA-Z0-9_]/', '', $name);
            if (empty($name)) continue;

            // بررسی و پاکسازی تعریف ستون
            $definition = trim(strtoupper($definition));
            $typeMatch = false;

            foreach ($validTypes as $validType) {
                if (strpos($definition, $validType) === 0) {
                    $typeMatch = true;
                    break;
                }
            }

            if (!$typeMatch) continue;

            // اضافه کردن تعریف معتبر
            $columnDefinitions[] = "`{$name}` {$definition}";
        }

        return $columnDefinitions;
    }

        // درج اطلاعات
    public function insert($request)
    {
        $tableName = $request->table_name;
        $data = $request->data;

        try {
            $result = $this->queryBuilder->table($tableName)->insert($data)->execute();
            return $this->handleResult($result, "Data inserted successfully", "Error inserting data");
        } catch(PDOException $e){
            return $this->jsonMsg(false, message: "Error inserting data : ". $e->getMessage(), status: HTTP_BadREQUEST);
        }
    }

    // به‌روزرسانی اطلاعات
    public function update($request)
    {
        $tableName = $request->table_name;
        $data = $request->data;
        $where = $request->where;

        try {
            $result = $this->queryBuilder->table($tableName)->where($where)->update($data)->execute();
            return $this->handleResult($result, "Data updated successfully", "Error updating data");
        } catch(PDOException $e){
            return $this->jsonMsg(false, message: "Error updating data : ". $e->getMessage(), status: HTTP_BadREQUEST);
        }
    }

    // حذف اطلاعات
    public function delete($request)
    {
        $tableName = $request->table_name;
        $where = $request->where;

        try {
            $result = $this->queryBuilder->table($tableName)->where($where)->delete()->execute();
            return $this->handleResult($result, "Data deleted successfully", "Error deleting data");
        } catch(PDOException $e){
            return $this->jsonMsg(false, message: "Error deleting data : ". $e->getMessage(), status: HTTP_BadREQUEST);
        }
    }


    // دریافت اطلاعات
    public function select($request)
    {
        $tableName = $request->table_name;
        $columns = $request->columns ?? ['*'];
        $where = $request->where ?? null;
        $orderBy = $request->order_by ?? null;
        $limit = $request->limit ?? null;

        $result = $this->queryBuilder->table($tableName)
            ->select($columns)
            ->where($where)
            ->orderBy($orderBy)
            ->limit($limit)
            ->getAll()->execute();

        if(is_string($result)) return $this->jsonMsg(false, message: "Error selecting data : " . $result, status: HTTP_BadREQUEST);
        else return $this->jsonMsg(true, message: "Data selected successfully", data: $result);
    }

    // اجرای کوئری دلخواه
    public function query($request)
    {
        $sql = $request->sql;

        try {
            $statement = $this->queryBuilder->getPdo()->prepare($sql);
            $statement->execute();

            // Check if it's a SELECT query
            if (stripos(trim($sql), 'SELECT') === 0) {
                $result = $statement->fetchAll(PDO::FETCH_ASSOC);
            } else {
                // For non-SELECT queries, you might return the number of affected rows or true/false
                $result = $statement->rowCount(); // Or simply true if you don't need the count
            }

            return $this->jsonMsg(true, "Query executed successfully", HTTP_OK, $result);

        } catch (PDOException $e) {
            return $this->jsonMsg(false, "Error executing query: " . $e->getMessage(), HTTP_BadREQUEST);
        }
    }
}