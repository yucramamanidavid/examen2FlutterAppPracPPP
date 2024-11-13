<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddEstadoToPracticasTable extends Migration
{
    public function up()
    {
        Schema::table('practicas', function (Blueprint $table) {
            $table->string('estado')->default('pendiente');
        });
    }

    public function down()
    {
        Schema::table('practicas', function (Blueprint $table) {
            $table->dropColumn('estado');
        });
    }
}
