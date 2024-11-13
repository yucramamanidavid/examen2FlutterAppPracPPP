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
        Schema::table('practicas', function (Blueprint $table) {
            $table->unsignedBigInteger('alumno_id')->after('id'); // Añadir el campo alumno_id después de la columna id
            $table->foreign('alumno_id')->references('id')->on('alumnos')->onDelete('cascade'); // Definir la relación con la tabla alumnos
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('practicas', function (Blueprint $table) {
            $table->dropForeign(['alumno_id']);
            $table->dropColumn('alumno_id');
        });
    }

};
