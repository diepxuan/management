<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table("products", function (Blueprint $table) {
            $table->bigInteger('nhanh_id')->nullable();
            $table->bigInteger('nhanh_categoryId')->nullable();
            $table->bigInteger('nhanh_parentId')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {

        Schema::table("apis", function (Blueprint $table) {
            $table->dropColumn([
                "nhanh_id",
                "nhanh_categoryId",
                "nhanh_parentId",
            ]);
        });
    }
};