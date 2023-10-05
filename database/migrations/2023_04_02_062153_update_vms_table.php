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
        if (Schema::hasColumn("vms", "enable")) {
            return;
        }
        Schema::table("vms", function (Blueprint $table) {
            $table
                ->boolean("is_allow")
                ->after("pub_host")
                ->nullable()
                ->default(0);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasColumn("vms", "is_allow")) {
            Schema::table("vms", function (Blueprint $table) {
                $table->dropColumn(["is_allow"]);
            });
        }
    }
};
