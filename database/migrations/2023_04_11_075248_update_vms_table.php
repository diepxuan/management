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
        //
        if (Schema::hasColumn("vms", "port")) {
            return;
        }
        Schema::table("vms", function (Blueprint $table) {
            $table->string("port")->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasColumn("vms", "port"))
            Schema::table("vms", function (Blueprint $table) {
                $table->dropColumn(["port"]);
            });
    }
};