import SwiftUI

struct CheckView: View {
    @StateObject private var vm = CheckHabitsViewModel()
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.App.background.ignoresSafeArea()
                VStack(spacing: 12) {
                    Text("Daily Habits")
                        .font(.custom("SeoulHangangEB", size: 32))
                        .foregroundColor(.App.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    List {
                        ForEach(vm.habits) { habit in
                            let hb = vm.binding(for: habit.id, fallback: habit)

                            NavigationLink {
                                HabitDetailView(
                                    habit: hb,
                                    onDelete: { vm.delete(id: habit.id) }
                                )
                            } label: {
                                HabitRow(
                                    habit: hb,
                                    onToggle: { withAnimation { vm.toggle(habit) } }
                                )
                            }
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: vm.delete)

                        Section {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.App.card)
                                .overlay(
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Quote of the day")
                                            .font(.custom("SeoulHangangM", size: 15))
                                            .foregroundColor(.App.textSecondary)
                                        Text("“No problem can be solved from the same level of consciousness that created it.”")
                                            .font(.custom("SeoulHangangM", size: 16))
                                            .foregroundColor(.App.textPrimary)
                                            .fixedSize(horizontal: false, vertical: true)
                                        HStack {
                                            Spacer()
                                            Text("— Albert Einstein")
                                                .font(.custom("SeoulHangangL", size: 14))
                                                .foregroundColor(.App.textSecondary)
                                        }
                                    }
                                    .padding(14)
                                )
                                .frame(height: 140)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.App.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddHabitView(viewModel: vm)
            }
        }
        .onAppear {
            NotificationService.shared.requestAuthorizationIfNeeded()
        }
    }
}
