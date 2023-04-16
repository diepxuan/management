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
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->string('code');
            $table->string('name')->nullable();
            $table->string('otherName')->nullable();

            $table->double('importPrice')->nullable();
            $table->double('oldPrice')->nullable();
            $table->double('price')->nullable();
            $table->double('wholesalePrice')->nullable();
            $table->double('vat')->nullable();

            $table->string('image')->nullable();
            $table->text('images')->nullable();
            $table->string('status')->nullable();
            $table->string('previewLink')->nullable();
            $table->boolean('showHot')->nullable();
            $table->boolean('showNew')->nullable();
            $table->boolean('showHome')->nullable();

            $table->string('unit')->nullable();
            $table->integer('width')->nullable();
            $table->integer('height')->nullable();
            $table->integer('length')->nullable();
            $table->integer('shippingWeight')->nullable();

            $table->string('warrantyAddress')->nullable();
            $table->string('warrantyPhone')->nullable();
            $table->string('warranty')->nullable();

            $table->integer('brandId')->nullable();
            $table->string('brandName')->nullable();
            $table->string('countryName')->nullable();

            $table->integer('typeId')->nullable();
            $table->string('typeName')->nullable();

            $table->integer('importType')->nullable();
            $table->string('importTypeLabel')->nullable();

            $table->double('avgCost')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};