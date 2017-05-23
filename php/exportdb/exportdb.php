<?php

error_reporting(E_ALL);
ini_set('error_reporting', E_ALL);
ini_set('display_errors', 1);
ini_set('memory_limit', '2048M');
ini_set('max_execution_time', 0);

date_default_timezone_set('Asia/Ho_Chi_Minh');

/**-------------------------------------------------------------*/
$db = new dbdump('localhost', 'ilg', 'evolve123', 'ilg');

$db->multi            = 0;
$db->sql_gz           = 0;
$db->sql_nomal        = 1;
$db->ins_length       = 200;
$db->table_max_length = 0;
$db->log              = false;
// magento
$db->dir = 'media';
// wordpress
// $db->dir          = 'wp-content/uploads';

$db->tables_dis = array(
    'adminnotification_inbox',
    'aw_core_logger',

    /* Cache tables */
    'core_cache',
    'core_cache_tag',

    /* Session tables */
    'core_session',

    'catalog_product_flat',
    'catalog_compare_item',
    'catalogindex_aggregation',
    'catalogindex_aggregation_tag',
    'catalogindex_aggregation_to_tag',

    /* Dataflow tables */
    'dataflow_batch_export',
    'dataflow_batch_import',

    /* Admin logs */
    'enterprise_logging_event',
    'enterprise_logging_event_changes',

    /*Support tables*/
    'enterprise_support_backup',
    'enterprise_support_backup_item',

    /* Index tables */
    'index_event',
    'index_process_event',

    /*Log tables*/
    'log_customer',
    'log_quote',
    'log_summary',
    'log_summary_type',
    'log_url',
    'log_url_info',
    'log_visitor',
    'log_visitor_info',
    'log_visitor_online',

    /* Report tables */
    'report_viewed_product_index',
    'report_compared_product_index',
    'report_event',

    /* More report tables */
    'report_viewed_product_aggregated_daily',
    'report_viewed_product_aggregated_monthly',
    'report_viewed_product_aggregated_yearly',
);

$db->tables_limit = array(
    'sales_flat_quote'                     => 'WHERE updated_at >= DATE_SUB(Now(),INTERVAL 30 DAY)',
    'sales_flat_quote_address'             => 'WHERE updated_at >= DATE_SUB(Now(),INTERVAL 30 DAY)',
    'sales_flat_quote_address_item'        => 'WHERE updated_at >= DATE_SUB(Now(),INTERVAL 30 DAY)',
    'sales_flat_quote_item'                => 'WHERE updated_at >= DATE_SUB(Now(),INTERVAL 30 DAY)',
    'sales_flat_quote_item_option'         => 'WHERE updated_at >= DATE_SUB(Now(),INTERVAL 30 DAY)',
    'sales_flat_quote_payment'             => 'WHERE updated_at >= DATE_SUB(Now(),INTERVAL 30 DAY)',
    'sales_flat_quote_shipping_rate'       => 'WHERE updated_at >= DATE_SUB(Now(),INTERVAL 30 DAY)',
    'enterprise_customer_sales_flat_quote' => 'WHERE updated_at >= DATE_SUB(Now(),INTERVAL 30 DAY)',

    /* only for developer */
    'core_url_rewrite'                     => 'WHERE is_system = 1',
    'enterprise_url_rewrite'               => 'WHERE is_system = 1',
);

$db->tables_clean = array(
    /* wordpress */
    'wp_options'            => "DELETE FROM `wp_options` WHERE `option_name` LIKE ('_transient%_feed_%')",
    'wp_terms'              => 'DELETE FROM wp_terms WHERE term_id IN (SELECT term_id FROM wp_term_taxonomy WHERE count = 0 )',
    'wp_term_taxonomy'      => 'DELETE FROM wp_term_taxonomy WHERE term_id not IN (SELECT term_id FROM wp_terms)',
    'wp_term_relationships' => 'DELETE FROM wp_term_relationships WHERE term_taxonomy_id not IN (SELECT term_taxonomy_id FROM wp_term_taxonomy)',
    'wp_posts'              => "DELETE FROM wp_posts WHERE post_status = 'trash'",
    'revisions'             => "DELETE a,b,c FROM wp_posts a WHERE a.post_type = 'revision' LEFT JOIN wp_term_relationships b ON (a.ID = b.object_id) LEFT JOIN wp_postmeta c ON (a.ID = c.post_id)",
    'comment_agent'         => "UPDATE wp_comments set comment_agent =''",
);

//wordpress
// $db->tables_dis     = array();

// $db->tables_limit   = array();

$db->tables_en = array();
// $db->tables_en = $db->tables_dis;
// $db->tables_en = array(
//   'wishlist_item_option',
//   'catalogsearch_fulltext',
//   'catalog_product_entity_text',
// );

// $db->table_from = 'sales_flat_quote';

$db->dumb();

// $db->clean();

// $db->file_delete('media' . DIRECTORY_SEPARATOR . 'lacoqueta');
// $db->file_delete('media' . DIRECTORY_SEPARATOR . 'orange');

// $db->file_chmod('media');
// $db->file_chmod('orange-box' . DIRECTORY_SEPARATOR . 'media');

/**-------------------------------------------------------------*/

/**
 *
 */
class dbdump extends stdClass
{

    public $host = '';
    public $user = '';
    public $pass = '';
    public $name = '';

    public $multi      = 0;
    public $dir        = 'media';
    public $ins_length = 100;
    public $sql_gz     = 1;
    public $sql_nomal  = 1;

    public $tables_en        = array();
    public $tables_dis       = array();
    public $tables_limit     = array();
    public $tables_clean     = array();
    public $table_from       = '';
    public $table_max_length = 250;
    public $log              = true;

    protected $tables = array();

    protected $mysql_data_type_hash = array(
        'number' => array(
            1   => 'tinyint',
            2   => 'smallint',
            3   => 'int',
            4   => 'float',
            5   => 'double',
            5   => 'real',
            7   => 'timestamp',
            8   => 'bigint',
            8   => 'serial',
            9   => 'mediumint',
            16  => 'bit',
            246 => 'decimal',
        ),
        'time'   => array(
            10 => 'date',
            11 => 'time',
            12 => 'datetime',
            13 => 'year',
        ),
        'bool'   => array(
            1  => 'boolean',
            16 => 'bit',
        ),
        'blob'   => array(
            252 => 'text',
            252 => 'tinyblob',
            252 => 'blob',
            252 => 'mediumblob',
            252 => 'longblob',
            254 => 'binary',
            253 => 'varbinary',
            16  => 'bit',
        ),
        'text'   => array(
            246 => 'decimal',
            252 => 'text', /* is currently mapped to all text and blob types (MySQL 5.0.51a) */
            253 => 'varchar',
            254 => 'char',
        ),
    );

    public function __construct($host = '', $user = '', $pass = '', $name = '', $dir = 'media', $ins_length = 100)
    {
        $this->host       = $host;
        $this->user       = $user;
        $this->pass       = $pass;
        $this->name       = $name;
        $this->dir        = $dir;
        $this->ins_length = $ins_length;

        // $this->dumb();
    }

    public function dumb()
    {

        $this->data_connect();
        $this->dumb_tables();
        $this->data_close();

        $this->log_out('successfull!!');
    }

    public function clean()
    {

        $this->data_connect();
        $this->clean_tables();
        $this->data_close();

        $this->log_out('successfull!!');
    }

    public function in_array_match($regex, $array)
    {

        if (!isset($regex) || !isset($array) || !is_string($regex) || !is_array($array)) {
            return false;
        }
        $regex = '/(.*)' . $regex . '(.*)/';
        foreach ($array as $v) {
            $match = preg_match($regex, $v);
            if ($match === 1) {
                return true;
            }
        }
        return false;
    }

    public function dumb_tables()
    {
        try {

            $sql = 'SHOW TABLES;';
            if (!$res_tables = $this->mysqli->query($sql)) {
                throw new Exception('MySQL Error: ' . $this->mysqli->error . 'SQL: ' . $sql);
            }

            while ($row = $res_tables->fetch_array()) {
                $this->tables[] = $row[0];
            }

            /* clean */
            $this->data_free($res_tables);

            if (!$this->multi) {
                $this->filename = $this->file_name();
                $this->file_open();
                $this->dumb_header();
            }

            $start = empty($this->table_from);
            foreach ($this->tables as $index => $table) {
                if (!$start) {
                    $start = strcmp($table, $this->table_from) >= 0;
                }
                if ($start) {
                    if (!empty($this->tables_en)) {
                        if ($this->in_array_match($table, $this->tables_en)) {
                            $this->dumb_table($table);
                        }
                    } else {
                        $this->dumb_table($table);
                    }
                    if ($this->table_max_length >= 1 && $index % $this->table_max_length == 0) {
                        $this->dumb_footer();
                        $this->file_close();
                        $this->filename = $this->file_name();
                        $this->file_open();
                        $this->dumb_header();
                    }
                }
            }

            if (!$this->multi) {
                $this->dumb_footer();
                $this->file_close();
            }

        } catch (Exception $e) {
            $this->log_out($e->getMessage());
        }
    }

    public function clean_tables()
    {
        try {

            foreach ($this->tables_dis as $table) {
                // TRUNCATE TABLE
                $sql = "TRUNCATE TABLE $table;";
                $this->mysqli->query($sql);
                // UPDATE AUTO_INCREMENT INDEX
                $sql = "ALTER TABLE $table AUTO_INCREMENT=1;";
                $this->mysqli->query($sql);
            }

            foreach ($this->tables_clean as $_query) {
                $sql = "$_query;";
                $this->mysqli->query($sql);
            }

        } catch (Exception $e) {
            $this->log_out($e->getMessage());
        }
    }

    public function dumb_table($table = '')
    {
        if ($this->multi) {
            $this->filename = $this->file_name($table);
            $this->file_open();
            $this->dumb_header();
        }

        $this->table_create($table);
        if (!$this->in_array_match($table, $this->tables_dis)) {
            $this->table_insert($table);
        }

        if ($this->multi) {
            $this->dumb_footer();
            $this->file_close();
        }
    }

    public function table_create($table = '')
    {
        try {

            $sql = 'SHOW CREATE TABLE ' . $table;
            if (!$res_create = $this->mysqli->query($sql)) {
                throw new Exception('MySQL Error: ' . $this->mysqli->error . 'SQL: ' . $sql);
            }
            $row_create = $res_create->fetch_assoc();

            /* clean */
            $this->data_free($res_create);

            $this->file_write('-- ' . PHP_EOL);
            $this->file_write('-- Table structure for table `' . $table . '`' . PHP_EOL);
            $this->file_write('-- ' . PHP_EOL);
            $this->file_write(PHP_EOL);
            $this->file_write('DROP TABLE IF EXISTS `' . $table . '`;' . PHP_EOL);
            $this->file_write('/*!40101 SET @saved_cs_client     = @@character_set_client */;' . PHP_EOL);
            $this->file_write('/*!40101 SET character_set_client = utf8 */;' . PHP_EOL);

            $this->file_write($row_create['Create Table'] . ';' . PHP_EOL);

            $this->file_write('/*!40101 SET character_set_client = @saved_cs_client */;' . PHP_EOL);
            $this->file_write(PHP_EOL);

            unset($row_create);

        } catch (Exception $e) {
            $this->log_out($e->getMessage());
        }
    }

    public function table_insert($table = '')
    {
        $this->file_write('-- ' . PHP_EOL);
        $this->file_write('-- Dump Data for `' . $table . '`' . PHP_EOL);
        $this->file_write('-- ' . PHP_EOL . PHP_EOL);

        $this->file_write("LOCK TABLES `$table` WRITE;" . PHP_EOL);
        $this->file_write("/*!40000 ALTER TABLE `$table` DISABLE KEYS */;" . PHP_EOL);

        try {

            $sql = "SELECT * FROM `$table` LIMIT 1;";
            if (!$res_select = $this->mysqli->query($sql)) {
                throw new Exception('MySQL Error: ' . $this->mysqli->error . 'SQL: ' . $sql);
            }

            $fields_info = $res_select->fetch_fields();

            /* clean */
            $this->data_free($res_select);

            $strFields = '';
            foreach ($fields_info as $field) {
                if ($strFields != '') {
                    $strFields .= ',';
                }

                $strFields .= '`' . $field->name . '`';
            }

            $sql       = "SELECT * FROM `$table`";
            $sql_limit = $sql;
            if (array_key_exists($table, $this->tables_limit)) {
                $where = $this->tables_limit[$table];
                $sql_limit .= " $where";
            }
            $sql .= ';';
            $sql_limit .= ';';
            if (!$res_select = $this->mysqli->query($sql_limit)) {
                if (!$res_select = $this->mysqli->query($sql)) {
                    throw new Exception('MySQL Error: ' . $this->mysqli->error . 'SQL: ' . $sql);
                }
                throw new Exception('MySQL Error: ' . $this->mysqli->error . 'SQL: ' . $sql_limit);
            }
            $_ins_max        = $res_select->num_rows;
            $_ins_number     = 1;
            $_ins_length     = 0;
            $_ins_str_length = 0;
            do {
                try {
                    $values    = $res_select->fetch_assoc();
                    $strValues = '';
                    foreach ($fields_info as $field) {
                        if ($strValues != '') {
                            $strValues .= ',';
                        }

                        $val = $values[$field->name];
                        if (is_null($val)) {
                            $val = 'NULL';
                        } elseif (in_array($field->type, array_keys($this->mysql_data_type_hash['text']))) {
                            $val = $this->sql_escape($val);
                            $val = "'$val'";
                        } elseif (is_numeric($val) && in_array($field->type, array_keys($this->mysql_data_type_hash['number']))) {
                            $val = $val;
                        } elseif (in_array($field->type, array_keys($this->mysql_data_type_hash['bool']))) {
                            $val = "0x$val";
                        } elseif (in_array($field->type, array_keys($this->mysql_data_type_hash['blob']))) {
                            $val = "0x$val";
                        } else {
                            $val = $this->sql_escape($val);
                            $val = "'$val'";
                        }

                        $strValues .= "$val";

                    }

                    if ($strValues && !empty($strValues)) {

                        if ($_ins_length >= $this->ins_length || $_ins_str_length >= $this->ins_length * 50) {
                            $_ins_length     = 0;
                            $_ins_str_length = 0;
                            $this->file_write(';' . PHP_EOL);
                            $_out = "INSERT IGNORE INTO `$table` ($strFields) VALUES ($strValues)";
                            $this->file_write($_out);
                            $_ins_str_length += strlen($_out);
                        } elseif ($_ins_length == 0) {
                            $_out = "INSERT IGNORE INTO `$table` ($strFields) VALUES ($strValues)";
                            $this->file_write($_out);
                            $_ins_str_length += strlen($_out);
                        } else {
                            $_out = ",($strValues)";
                            $this->file_write($_out);
                            $_ins_str_length += strlen($_out);
                        }

                    }
                } catch (Exception $e) {
                    $this->log_out($e->getMessage());
                }
                $_ins_length += 1;
                $_ins_number += 1;
            } while ($_ins_number <= $_ins_max);

            /* clean */
            $this->data_free($res_select);

            if ($_ins_length >= 1) {
                $this->file_write(';' . PHP_EOL);
            }

        } catch (Exception $e) {
            $this->log_out($e->getMessage());
        }

        $this->file_write("/*!40000 ALTER TABLE `$table` ENABLE KEYS */;" . PHP_EOL);
        $this->file_write('UNLOCK TABLES;' . PHP_EOL);

        /**-------------------------------------------------------------*/

        $this->file_write(PHP_EOL);
    }

    public function dumb_header()
    {
        $this->file_write('-- [DB] SQL Dump' . PHP_EOL);
        $this->file_write('-- ' . PHP_EOL);
        $this->file_write('-- Server version:' . $this->mysqli->server_info . PHP_EOL);
        $this->file_write('-- Generated: ' . date('Y-m-d h:i:s') . PHP_EOL);
        $this->file_write('-- ' . PHP_EOL);
        $this->file_write('-- Current PHP version: ' . phpversion() . PHP_EOL);
        $this->file_write('-- Host: ' . $this->host . PHP_EOL);
        $this->file_write('-- Database: ' . $this->name . PHP_EOL);
        $this->file_write('-- ------------------------------------------------------' . PHP_EOL . PHP_EOL);

        $this->file_write('/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;' . PHP_EOL);
        $this->file_write('/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;' . PHP_EOL);
        $this->file_write('/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;' . PHP_EOL);
        $this->file_write('/*!40101 SET NAMES utf8 */;' . PHP_EOL);
        $this->file_write('/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;' . PHP_EOL);
        $this->file_write("/*!40103 SET TIME_ZONE='+00:00' */;" . PHP_EOL);
        $this->file_write('/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;' . PHP_EOL);
        $this->file_write('/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;' . PHP_EOL);
        $this->file_write("/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO,ALLOW_INVALID_DATES' */;" . PHP_EOL);
        $this->file_write('/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;' . PHP_EOL);
        $this->file_write(PHP_EOL . PHP_EOL);
    }

    public function dumb_footer()
    {
        $this->file_write(PHP_EOL . PHP_EOL);
        $this->file_write('/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;' . PHP_EOL . PHP_EOL);
        $this->file_write('/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;' . PHP_EOL);
        $this->file_write('/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;' . PHP_EOL);
        $this->file_write('/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;' . PHP_EOL);
        $this->file_write('/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;' . PHP_EOL);
        $this->file_write('/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;' . PHP_EOL);
        $this->file_write('/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;' . PHP_EOL);
        $this->file_write('/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;' . PHP_EOL);
    }

    public function data_connect()
    {
        try {
            if (!function_exists('mysqli_connect')) {
                throw new Exception(' This scripts need mysql extension to be running properly ! please resolve!!');
            }

            $this->mysqli = new mysqli($this->host, $this->user, $this->pass, $this->name);
            if ($this->mysqli->connect_errno) {
                throw new Exception('Failed to connect to MySQL: ' . $this->mysqli->connect_error);
            }

            $this->mysqli->set_charset('utf8');
        } catch (Exception $e) {
            $this->log_out($e->getMessage());
        }
    }

    public function data_close()
    {
        try {
            $this->mysqli->close();
        } catch (Exception $e) {
            $this->log_out($e->getMessage());
        }
    }

    public function data_free(&$res)
    {
        try {
            $res->free_result();
        } catch (Exception $e) {
            $this->log_out($e->getMessage());
        }
        try {
            $res->free();
        } catch (Exception $e) {
            $this->log_out($e->getMessage());
        }
        try {
            $res->close();
        } catch (Exception $e) {
            $this->log_out($e->getMessage());
        }
        try {
            unset($res);
        } catch (Exception $e) {
            $this->log_out($e->getMessage());
        }
    }

    public function file_name($table = '')
    {
        if (!file_exists($this->dir . DIRECTORY_SEPARATOR)) {
            mkdir($this->dir . DIRECTORY_SEPARATOR, 0777, true);
        }
        if (!empty($table)) {
            if (!file_exists($this->dir . DIRECTORY_SEPARATOR . $this->name . DIRECTORY_SEPARATOR)) {
                mkdir($this->dir . DIRECTORY_SEPARATOR . $this->name . DIRECTORY_SEPARATOR, 0777, true);
            }
            $this->filename = sprintf('%s%s%s%s%s_%s_%s.sql', $this->dir, DIRECTORY_SEPARATOR, $this->name, DIRECTORY_SEPARATOR, $this->name, $table, date('Y-m-d--H-i-s'));
            return $this->filename;
        } else {
            $this->filename = sprintf('%s%s%s_%s.sql', $this->dir, DIRECTORY_SEPARATOR, $this->name, date('Y-m-d--H-i-s'));
            return $this->filename;
        }
    }

    public function file_open()
    {
        if ($this->sql_nomal) {
            $this->handle = fopen($this->filename, 'w');
            stream_set_blocking($this->handle, 0);
        }
        if ($this->sql_gz) {
            $this->handle_gz = gzopen("$this->filename.gz", 'w9');
        }
        ob_start();
    }

    public function file_write($buffer = '')
    {
        usleep(50);
        if ($this->sql_nomal) {
            if (flock($this->handle, LOCK_EX)) {
                fwrite($this->handle, $buffer);
            }
            flock($this->handle, LOCK_UN);
        }
        if ($this->sql_gz) {
            gzwrite($this->handle_gz, $buffer);
        }
        // $this->log_out(nl2br($buffer));
        return;
    }

    public function file_close()
    {
        $this->file_write(ob_get_clean());
        if ($this->sql_nomal) {
            fclose($this->handle);
        }
        if ($this->sql_gz) {
            gzclose($this->handle_gz);
        }
    }

    public function file_delete($path = '')
    {
        if (is_dir($path) === true) {
            $files = array_diff(scandir($path), array('.', '..'));

            foreach ($files as $file) {
                $this->file_delete(realpath($path) . DIRECTORY_SEPARATOR . $file);
            }

            return rmdir($path);
        } else if (is_file($path) === true) {
            return unlink($path);
        }

        return false;
    }

    public function file_chmod($path = '.', $permission = 0777)
    {

        $ignore = array('cgi-bin', '.', '..');

        if (is_dir($path) === true) {
            $files = array_diff(scandir($path), $ignore);
            if (@chmod($path, $permission)) {
                $this->log_out('Folder permissions changed');
            } else {
                $this->log_out('Failed to change permissions');
            }

            foreach ($files as $file) {
                $this->file_chmod(realpath($path) . DIRECTORY_SEPARATOR . $file);
            }
        } else if (is_file($path) === true) {
            chmod($path, $permission);
            if (@chmod($path, $permission)) {
                $this->log_out('Folder permissions changed');
            } else {
                $this->log_out('Failed to change permissions');
            }
        }

        return false;
    }

    public function sql_escape($sql)
    {
        if (@isset($sql)) {
            // $sql = @trim($sql);
            // $sql = @addslashes($sql);
            // if(get_magic_quotes_gpc()) {
            //   $sql = @stripslashes($sql);
            // }
            // $sql = str_replace('www.wemakefootballers.com', 'local.dev/wmf', $sql);
            $sql = str_replace('int.evolveretail.com/~', 'local.dev/', $sql);
            $sql = $this->mysqli->real_escape_string($sql);
        } else {
            $sql = 'NULL';
        }
        return $sql;
    }

    public function log_is_enable()
    {
        return $this->log;
    }

    public function log_out($log = '')
    {
        if ($this->log_is_enable()) {
            echo nl2br($log . PHP_EOL) . PHP_EOL;
        }
    }

}
