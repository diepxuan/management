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
            $table->string('name');
            $table->string('otherName');

            $table->double('importPrice');
            $table->double('oldPrice');
            $table->double('price');
            $table->double('wholesalePrice');
            $table->double('vat');

            $table->string('image');
            $table->text('images');
            $table->string('status');
            $table->string('previewLink');
            $table->boolean('showHot');
            $table->boolean('showNew');
            $table->boolean('showHome');

            $table->integer('unit');
            $table->integer('width');
            $table->integer('height');
            $table->integer('length');
            $table->integer('shippingWeight');

            $table->string('warrantyAddress');
            $table->string('warrantyPhone');
            $table->string('warranty');

            $table->integer('brandId');
            $table->string('brandName');
            $table->string('countryName');

            $table->integer('typeId');
            $table->string('typeName');

            $table->integer('importType');
            $table->string('importTypeLabel');

            $table->double('avgCost');
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