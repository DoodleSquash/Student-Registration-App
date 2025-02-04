from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from flask_migrate import Migrate

app = Flask(__name__)
CORS(app)  # Enable CORS
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///students.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)
migrate = Migrate(app, db)  # Add this line

class Student(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    student_number = db.Column(db.String(100), nullable=False)
    age = db.Column(db.Integer, nullable=False)
    phone_number = db.Column(db.String(100), nullable=False)
    image = db.Column(db.Text, nullable=True)  # Add this line

    def serialize(self):
        return {
            'id': self.id,
            'name': self.name,
            'student_number': self.student_number,
            'age': self.age,
            'phone_number': self.phone_number,
            'image': self.image,  # Add this line
        }

@app.route('/students', methods=['POST'])
def create_student():
    data = request.get_json()
    new_student = Student(
        name=data['name'],
        student_number=data['student_number'],
        age=data['age'],
        phone_number=data['phone_number'],
        image=data.get('image', ''),  # Add this line
    )
    db.session.add(new_student)
    db.session.commit()
    return jsonify(new_student.serialize()), 201

@app.route('/students', methods=['GET'])
def get_students():
    students = Student.query.all()
    return jsonify([student.serialize() for student in students]), 200

@app.route('/students/<int:id>', methods=['GET'])
def get_student(id):
    student = Student.query.get_or_404(id)
    return jsonify(student.serialize()), 200

@app.route('/students/<int:id>', methods=['PUT'])
def update_student(id):
    data = request.get_json()
    student = Student.query.get_or_404(id)
    student.name = data['name']
    student.student_number = data['student_number']
    student.age = data['age']
    student.phone_number = data['phone_number']
    student.image = data.get('image', student.image)  # Add this line
    db.session.commit()
    return jsonify(student.serialize()), 200

@app.route('/students/<int:id>', methods=['DELETE'])
def delete_student(id):
    student = Student.query.get_or_404(id)
    db.session.delete(student)
    db.session.commit()
    reassign_ids()
    return jsonify({'message': 'Student deleted'}), 204

def reassign_ids():
    students = Student.query.order_by(Student.id).all()
    for index, student in enumerate(students):
        student.id = index + 1
    db.session.commit()

if __name__ == '__main__':
    with app.app_context():
        db.create_all()  # This line creates the database tables within the application context
    app.run(host='0.0.0.0', port=5000, debug=True)  # Listen on all available IP addresses