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

        if (Schema::hasColumn("vms", "version")) {
            return;
        }
        Schema::table("vms", function (Blueprint $table) {
            $table->string("gateway")->after("pub_host")->nullable();
            $table->string("version")->after("gateway")->nullable();
            $table->string("parent_id")->after("vm_id")->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasColumn("vms", "gateway"))
            Schema::table("vms", function (Blueprint $table) {
                $table->dropColumn(["gateway"]);
            });

        if (Schema::hasColumn("vms", "version"))
            Schema::table("vms", function (Blueprint $table) {
                $table->dropColumn(["version"]);
            });
        if (Schema::hasColumn("vms", "parent_id"))
            Schema::table("vms", function (Blueprint $table) {
                $table->dropColumn(["parent_id"]);
            });
    }
};