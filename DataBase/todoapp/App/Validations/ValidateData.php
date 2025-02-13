<?php

namespace App\Validations;

use App\Traits\ResponseTrait;
use App\Database\QueryBuilder;

trait ValidateData
{
    use ResponseTrait;
    
    protected $queryBuilder;

    public function __construct()
    {
        $this->queryBuilder = new QueryBuilder();
    }

    public function validate($fields = [], $request){
        if(count($fields)){
            $isError = false;
            $errorsMessages = [];

            foreach ($fields as $field){
                $items = explode("||", $field);
                $itemsCount = count($items);
//                dd($items[1]);
                if($itemsCount == 2){
                    $validations_param_string = $items[1];
                    $validations = explode('|', $validations_param_string);

                    foreach ($validations as $validation){
                        $key = $items[0];

                        // required validation
                        if($validation == "required"){
                            if(!isset($request->$key) || empty($request->$key)) $isError = true && array_push($errorsMessages, "لطفا " . translate_key($key) . " را وارد کنید");
                        }

                        // check string value
                        if($validation == "string"){
                            if(isset($request->$key)) if(!is_string($request->$key)) $isError = true && array_push($errorsMessages, "مقدار " . translate_key($key) . " باید یک رشته باشد");
                        }

                        // check int|number value
                        if($validation == "int" || $validation == "number"){
                            if(isset($request->$key)) if(!is_int($request->$key)) $isError = true && array_push($errorsMessages, "مقدار " . translate_key($key) . " باید یک عدد باشد");
                        }

                        // check int|number value
                        if($validation == "bool" || $validation == "boolean"){
                            if(isset($request->$key)) if(!is_bool($request->$key)) $isError = true && array_push($errorsMessages, "مقدار " . translate_key($key) . " باید یک عبارت منظقی (true یا false) باشد");
                        }

                        // min chars validation
                        if(str_contains($validation, "min")){
                            $min_value = (int)explode(':', $validation)[1];
                            if(isset($request->$key)) if(mb_strlen($request->$key) < $min_value) $isError = true && array_push($errorsMessages, "مقدار " . translate_key($key) . " باید حداقل ".$min_value." کارکتر باشد");
                        }

                        // max chars validation
                        if(str_contains($validation, "max")){
                            $max_value = (int)explode(':', $validation)[1];
                            if(isset($request->$key)) if(mb_strlen($request->$key) > $max_value) $isError = true && array_push($errorsMessages, "مقدار " . translate_key($key) . " نمیتواند بیشتر از  ".$max_value." کارکتر باشد");
                        }

                        // check chars length
                        if(str_contains($validation, "length")){
                            $length_value = (int)explode(':', $validation)[1];
                            if(isset($request->$key)) if(mb_strlen($request->$key) != $length_value) $isError = true && array_push($errorsMessages, "مقدار " . translate_key($key) . " باید برابر با ".$length_value." کارکتر باشد");
                        }
                    }
                } else if($itemsCount == 1){
                    if(!isset($request->$field) || empty($request->$field)) $isError = true && array_push($errorsMessages, "لطفا " . translate_key($field) . " را وارد کنید");
                } else {
                    $this->jsonMsg(success: false, message: "ورودی های ولیدیشن شما اشتباه است", status: HTTP_BadREQUEST);
                    return exit();
                }
            }

            if($isError){
                $this->jsonMsg(success: false, message: implode(", ", $errorsMessages), status: HTTP_BadREQUEST);
                return exit();
            }
        } return true;
    }

    public function validateTableCreation($request): bool {
        $requiredFields = ['table_name', 'columns'];

        foreach ($requiredFields as $field) {
            if (!isset($request->$field)) {
                return false;
            }
        }

        if (!is_array($request->columns)) {
            return false;
        }

        // Add additional validation for column names and types
        return true;
    }

    /**
     * Checks if a value is unique in a given table and key.
     *
     * @param string $table The name of the table to check.
     * @param string $key The key to check for uniqueness.
     * @param mixed $value The value to check for uniqueness.
     *
     * @return void
     */
    public function checkUnique($table, $key, $value)
    {
        // Check if the table, key, and value are not empty
        if (empty($table) || empty($key) || empty($value)) {
            $this->jsonMsg(success: false, message: "Table, key, and value are required", status: HTTP_BadREQUEST);
            return exit();
        }

        // Unique resource check
        $hasResource = $this->queryBuilder->table($table)
            ->where($key, '=', $value)
            ->get()->execute();

        // Check if the query execution was successful
        if ($hasResource !== false) {
            // If the resource exists, return an error message
            $this->jsonMsg(success: false, message: "مقدار " . translate_key($key) . " تکراری است یا از قبل وجود دارد!", status: HTTP_BadREQUEST);
            return exit();
        }
    }
}