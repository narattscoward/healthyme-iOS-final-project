//
//  HabitTab.swift
//  Final_Project
//
//  Created by Wyne Nadi on 18/10/2568 BE.
//

import SwiftUI
import Combine

//Model
struct Habit : Identifiable {
    let id: UUID
    var name : String
    var time : Date
    var notify : Bool
    var notes : String
    var isDone : Bool
    
    init(id: UUID = UUID(),
         name: String,
         time: Date = Date(),
         notify: Bool = true,
         notes: String = "",
         isDone : Bool = false) {
        self.id = id
        self.name = name
        self.time = time
        self.notify = notify
        self.notes = notes
        self.isDone = isDone
    }
}

// View Model (UI only)
@MainActor
final class HabitVM : ObservableObject {
    
    @Published var habits: [Habit] = [
        Habit(name: "Gratitude journaling", time: HabitVM.makeTime(hour: 20, min: 30), notes : "Write down 3 things you are thankful for."),
        Habit(name: "Morning meditation", time: HabitVM.makeTime(hour: 6, min: 30), notes : "Spend 5-10 minutes meditating."),
        Habit(name: "Read a book", time: HabitVM.makeTime(hour: 8, min: 0), notes : "Choose a book to read and dedicate 30 minutes to it.")
    ]
    
    func add(_ habit : Habit) { habits.append(habit)}
    
    func delete(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
    }
    
    func toggle(_ habit : Habit) {
        guard let idx = habits.firstIndex(where : {$0.id == habit.id}) else { return }
        habits[idx].isDone.toggle()
    }
    
    static func makeTime(hour: Int, min: Int) -> Date {
        var comps = DateComponents()
        comps.hour = hour; comps.minute = min
        return Calendar.current.date(from: comps) ?? Date()
    }
}

// Habit Tab
struct HabitTab: View {
    
    @StateObject private var vm = HabitVM()
    @State private var showingAdd = false
    
    private let mint = Color(hexCode: "#A8E6CF")
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(vm.habits) { habit in NavigationLink {
                        HabitDetailView(habit: habit, mint: mint) { updated in
                            if let idx = vm.habits.firstIndex(where: { $0.id == updated.id }) {
                                vm.habits[idx] = updated
                            }
                        } onDelete: {
                            vm.delete(habit)
                        }
                    } label : {
                        HabitRow(habit: habit, mint: mint) {
                            vm.toggle(habit)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { vm.delete(habit)} label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    }
                }
                //Quote Card
                Section {
                    QuoteCard(
                        title : "Quote of the day",
                        quote : "No problem can be solved from the same levles of consciousness that created it.",
                        author : "Albert Einstein",
                        mint: mint
                    )
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Daily Habits")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                    showingAdd = true
                    } label : {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(mint)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddHabitSheet(mint: mint) { newHabit in vm.add(newHabit)
            }
            .presentationDetents([.height(520), .large])
        }
    }
}

// Row
struct HabitRow: View {
    let habit: Habit
    let mint: Color
    var onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: habit.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(habit.isDone ? mint : .secondary)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            
            Text(habit.name)
                .foregroundStyle(.primary)
                .strikethrough(habit.isDone, color: mint.opacity(0.9))
            
            Spacer()
        }
        .padding(.vertical, 6)
    }
}

// Quote Card
struct QuoteCard : View {
    let title: String
    let quote: String
    let author: String
    let mint : Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("\"\(quote)\"")
                    .italic()
                    .foregroundStyle(mint)
                Text("- \(author)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(mint.opacity(0.12))
            )
        }
    }
}

// Add Habit Sheet
struct AddHabitSheet : View {
    let mint : Color
    var onAdd : (Habit) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name : String = ""
    @State private var time : Date = HabitVM.makeTime(hour: 8, min: 0)
    @State private var notify : Bool = true
    @State private var notes : String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Enter the name of the habit", text: $name)
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                    Toggle("Notification", isOn: $notify)
                }
                Section("Description") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.gray.opacity(0.15)))
                        .background(mint.opacity(0.06))
                }
                Section {
                    Button {
                        let habit = Habit(name: name, time: time, notify: notify, notes: notes)
                        onAdd(habit)
                        dismiss()
                    } label: {
                        Text("Add Habit")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(mint)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .tint(mint)
            .navigationTitle("Add a habit")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Details Screen
struct HabitDetailView : View {
    @State var habit : Habit
    let mint : Color
    var onSave : (Habit) -> Void
    var onDelete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body  : some View {
        Form {
            Section {
                LabeledContent("Habit") {
                    TextField("Name", text: $habit.name)
                        .multilineTextAlignment(.trailing)
                }
                DatePicker("Time", selection: $habit.time, displayedComponents: .hourAndMinute)
                Toggle("Notification", isOn: $habit.notify)
            }
            
            Section("Description") {
                TextEditor(text: $habit.notes)
                    .frame(minHeight: 140)
                    .padding(4)
                    .background(mint.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Section {
                Button(role: .destructive) {
                    onDelete()
                    dismiss()
                } label : {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                }
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Save") {
                    onSave(habit)
                    dismiss()
                }
                .tint(mint)
            }
        }
    }
}

#Preview {
    HabitTab()
}
