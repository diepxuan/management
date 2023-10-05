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
        if (Schema::hasColumn("apis", "enable"))
            return;

        Schema::table("apis", function (Blueprint $table) {
            $table->boolean("enable")->nullable()->default(0);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {

        if (Schema::hasColumn("apis", "enable"))
            Schema::table("apis", function (Blueprint $table) {
                $table->dropColumn(["enable"]);
            });
    }
};