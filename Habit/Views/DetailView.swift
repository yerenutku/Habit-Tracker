//
//  DetailView.swift
//  Habit
//
//  Created by Nazarii Zomko on 21.07.2023.
//

import SwiftUI


struct DetailView: View {
    @ObservedObject var habit: Habit
    @AppStorage("overviewPageIndex") private var overviewPageIndex = 0
    
    private var completedDates: Binding<[DateComponents]> {
        Binding(
            get: { habit.completedDates.asDateComponents },
            set: { newValue in
                habit.completedDates = newValue.asDates
                dataController.save()
            }
        )
    }
    
    @EnvironmentObject var dataController: DataController
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                regularityAndReminder
                overview
                ChartView(dates: habit.completedDates, color: habit.color)
                    .padding([.horizontal, .bottom])
                CalendarView(dateInterval: .init(start: .distantPast, end: .today()), completedDates: completedDates, color: habit.color)
            }
            .navigationTitle("\(habit.title)")
            .toolbarBackground(Color(habit.color), for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    NavigationLink("Edit") {
                        EditHabitView(habit: habit)
                    }
                    .foregroundColor(.black)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
            }
            .onAppear {
                setupAppearance()
            }
        }
    }
    
    var regularityAndReminder: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("REGULARITY")
                    .font(.caption.bold())
                Text("every day")
            }
            .padding(.leading)
            .padding(.trailing, 70)

            VStack(alignment: .leading) {
                Text("REMIND ME")
                    .font(.caption.bold())
                Text("--:--")
            }
            Spacer()
        }
        .foregroundColor(.black)
        .padding(.top, 40)
        .padding(.bottom, 15)
        .background(alignment: .bottom, content: {
            Color(habit.color)
                .frame(height: 500)
        })
    }
    
    var overview: some View {
        ZStack(alignment: .topLeading) {
            TabView(selection: $overviewPageIndex) {
                OverviewView(title: "Habit Strength", mainText: "\(habit.strengthPercentage)%", secondaryText1: "Month: +\(habit.strengthGainedWithinLastDays(daysAgo: 30))%", secondaryText2: "Year: +\(habit.strengthGainedWithinLastDays(daysAgo: 365))%").tag(0)     // Note: There is no point in calculating strength gained in last year because with current formula strengthGainedInYear will always be equal to strengthPercentage.
                OverviewView(title: "Completions", mainText: "\(habit.completedDates.count)", secondaryText1: "Month: +\(habit.completionsWithinLastDays(daysAgo: 30))", secondaryText2: "Year: +\(habit.completionsWithinLastDays(daysAgo: 365))").tag(1)
                OverviewView(title: "Streak", mainText: "\(habit.streak) days", secondaryText1: "Longest Streak: \(habit.longestStreak) days", secondaryText2: "").tag(2)
            }
            .tabViewStyle(.page)
            .frame(height: 190)
            
            Text("OVERVIEW")
                .font(.caption.bold())
                .padding()
        }
    }
    
    func setupAppearance() {
        // Fixes SwiftUI bug where paging dots are white in Light Mode.
        let color = UIColor.label
        UIPageControl.appearance().currentPageIndicatorTintColor = color
        UIPageControl.appearance().pageIndicatorTintColor = color.withAlphaComponent(0.4)
    }
    
    struct OverviewView: View {
        var title: String
        var mainText: String
        var secondaryText1: String
        var secondaryText2: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(title)")
                    .font(.title3.bold())
                HStack() {
                    VStack(alignment: .leading) {
                        VStack() {
                            Text("\(mainText)")
                                .font(.system(size: 50).bold())
                        }
                        HStack {
                            Text("\(secondaryText1)")
                                .padding(.trailing, 60)
                            Text("\(secondaryText2)")
                        }
                    }
                    .foregroundColor(.primary)
                    Spacer()
                }
            }
            .padding()
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(habit: Habit.example)
            .previewLayout(.sizeThatFits)
    }
}


