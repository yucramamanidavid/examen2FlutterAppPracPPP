<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddEvidenciaPathToPracticasTable extends Migration
{
    public function up()
    {
        Schema::table('practicas', function (Blueprint $table) {
            $table->string('evidencia_path')->nullable();
        });
    }

    public function down()
    {
        Schema::table('practicas', function (Blueprint $table) {
            $table->dropColumn('evidencia_path');
        });
    }
}

