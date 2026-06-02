package com.subms.student.model;

import jakarta.persistence.*;

@Entity
@Table(name = "assignment_questions")
public class AssignmentQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int question_id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assignment_id", nullable = false)
    private Assignment assignment;

    @Column(name = "question_text", nullable = false, columnDefinition = "TEXT")
    private String questionText;

    @Column(name = "question_type", nullable = false)
    private String questionType; // "MCQ", "FITB", "EXACT"

    @Column(name = "choices", columnDefinition = "TEXT")
    private String choices; // Store as comma-separated or JSON string

    @Column(name = "correct_answer", nullable = false)
    private String correctAnswer;

    @Column(name = "points")
    private int points = 1;

    public AssignmentQuestion() {}

    // --- Getters and Setters ---
    public int getQuestion_id() { return question_id; }
    public void setQuestion_id(int question_id) { this.question_id = question_id; }

    public Assignment getAssignment() { return assignment; }
    public void setAssignment(Assignment assignment) { this.assignment = assignment; }

    public String getQuestionText() { return questionText; }
    public void setQuestionText(String questionText) { this.questionText = questionText; }

    public String getQuestionType() { return questionType; }
    public void setQuestionType(String questionType) { this.questionType = questionType; }

    public String getChoices() { return choices; }
    public void setChoices(String choices) { this.choices = choices; }

    public String getCorrectAnswer() { return correctAnswer; }
    public void setCorrectAnswer(String correctAnswer) { this.correctAnswer = correctAnswer; }

    public int getPoints() { return points; }
    public void setPoints(int points) { this.points = points; }
}