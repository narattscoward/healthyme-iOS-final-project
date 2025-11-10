import SwiftUI

struct CheckView: View {
    @EnvironmentObject private var vm: CheckHabitsViewModel
    @State private var showingAdd = false
    @EnvironmentObject private var languageManager: LanguageManager

    private var b: Bundle { languageManager.bundle }

    var body: some View {
        ZStack {
            Color.App.background.ignoresSafeArea()

            List {
                // --- QUOTE SECTION FIRST ---
                Section {
                    QuoteCard(
                        text: vm.quoteText,
                        author: vm.quoteAuthor,
                        isLoading: vm.isLoadingQuote,
                        error: vm.quoteError,
                        onRetry: { Task { await vm.refreshQuote(force: true) } }
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                // --- HABIT LIST ---
                Section {
                    if vm.habits.isEmpty {
                        Text(L("check.emptyState", b))
                            .font(.custom("SeoulHangangM", size: 14))
                            .foregroundColor(.App.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 16)
                            .listRowBackground(Color.clear)
                    } else {
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
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.App.primary)
                        .accessibilityLabel(Text(L("check.addHabit", b)))
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddHabitView(viewModel: vm)
        }
        .task { await vm.refreshQuote() }
        .onAppear { NotificationService.shared.requestAuthorizationIfNeeded() }
    }
}
