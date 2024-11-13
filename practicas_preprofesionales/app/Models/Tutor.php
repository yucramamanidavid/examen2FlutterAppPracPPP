<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Tutor extends Model
{
    use HasFactory;
    protected $table = 'tutores';
    protected $fillable = [
        'nombre',
        'email',
        'user_id', // ID del usuario asociado
        'password', // Agregar password a los campos fillable
    ];
    // Mutador para hashear la contraseña automáticamente al guardar
    public function setPasswordAttribute($value)
    {
        $this->attributes['password'] = bcrypt($value);
    }
    // Relación con el usuario
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Relación con los alumnos
    public function alumnos()
     {
         return $this->belongsToMany(Alumno::class, 'alumno_tutor', 'tutor_id', 'alumno_id');
     }
    // public function alumnos()
    // {
    //     return $this->hasMany(Alumno::class);
    // }

}
