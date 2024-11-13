<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('tutores', function (Blueprint $table) {
            $table->string('password')->nullable(); // Agrega el campo password a la tabla tutores
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('tutores', function (Blueprint $table) {
            $table->dropColumn('password'); // Elimina el campo password en caso de rollback
        });
    }
};
