//
//  NewTaskHome.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/15/23.
//

// connect background with weather
import FirebaseFirestoreSwift
import SwiftUI
import SpriteKit

struct NewTaskView: View {
    @State private var currentDate: Date = .init()
    @State private var weekSlider: [[Date.WeekDay]] = []
    @State private var currentWeekIndex: Int = 1
    @Namespace private var animation
    @State private var createWeek: Bool = false
    @StateObject var viewModel: TaskViewModel
    @StateObject var shareViewModel = ShareViewModel()
    @State private var drawShowing: Bool = false
    @State private var shareShowing: Bool = false
    @FirestoreQuery var items: [TasksItem]
    @StateObject var location: locationController = locationController()
    @State var weather:String = ""
    @State var backImage = "sunny"
    @State var changeWeather = true
    @State var userId = ""
    @State var response = false
    @State var prompt = ""
    
    init(userId: String){
        self._items = FirestoreQuery(collectionPath: "users/\(userId)/tasks")
        self._viewModel = StateObject(wrappedValue: TaskViewModel(userId: userId))
        self.userId = userId
    }
    
    var body: some View {
        NavigationView{
            ZStack{
                if weather == "rain" {
                    GeometryReader{_ in
                        HStack{
                            SpriteView(scene: RainFall(size: UIScreen.main.bounds.size),options: [.allowsTransparency]).offset(y:-187).frame(width:240,height: 160)
                            SpriteView(scene: RainFall(size: UIScreen.main.bounds.size),options: [.allowsTransparency]).offset(y:-150).frame(height: 245)
                        }
                    }
                }
                VStack(alignment: .leading,spacing: 0) {
                        HeaderView()
                    List(items){ item in
                        if Date(timeIntervalSince1970: 0).addingTimeInterval(item.dueDate).isWithin(date: currentDate) {
                            TaskItemView(item: item)
                                .onTapGesture(count: 2,perform: {
                                    prompt = item.title
                                    response = true
                                })
                                .swipeActions(){
                                    Button("Delete"){
                                        viewModel.delete(id: item.id)
                                    }
                                    .tint(.red)
                                }
                                .swipeActions(edge: .leading){
                                    Button("Share"){
                                        shareShowing = true
                                        shareViewModel.setUp(item: item)
                                    }
                                    .tint(.blue)
                                }
                                .listRowBackground(
                                    Color.white.opacity(0.8).cornerRadius(15).frame(height: 55))
                                .frame(idealHeight: 37)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .frame(width: 395)
                    .offset(x:17)
                }
                .vSpacing(.top)
                .task {
                    await fetchWeatherIfNeeded()
                }
                .onAppear(){
                    if weekSlider.isEmpty {
                        let currentWeek = Date().fetchWeek()
                        
                        if let firstDate = currentWeek.first?.date{
                            weekSlider.append(firstDate.createPrevWeek())
                        }
                        
                        weekSlider.append(currentWeek)
                        
                        if let lastDate = currentWeek.last?.date{
                            weekSlider.append(lastDate.createNextWeek())
                        }
                    }
                }
                .navigationTitle("Tasks")
                .toolbar{
//                    Button{
//                        drawShowing = true
//                    }
//                label:{
//                        ZStack{
//                            Rectangle().cornerRadius(15).frame(width: 40,height: 40)
//                                .foregroundColor(.white)
//                                .opacity(1)
//                            Image(systemName: "pencil")
//                        }
//                    }
                    Button{
                        viewModel.showingNewItemView = true
                    } label:{
                        ZStack{
                            Rectangle().cornerRadius(15).frame(width: 40,height: 40)
                                .foregroundColor(.white)
                                .opacity(1)
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $viewModel.showingNewItemView){
                    NewItemView(newItemPresented: $viewModel.showingNewItemView)
                        .presentationDetents([.height(650)])
                }
                .sheet(isPresented: $drawShowing){
                    DrawView(id: userId)
                        .presentationDetents([.height(650)])
                }
                .sheet(isPresented: $shareShowing){
                    ShareView(viewModel: shareViewModel)
                        .presentationDetents([.height(240)])
                }
                .sheet(isPresented: $response){
                    SearchView(title: $prompt).onDisappear(){prompt = ""}
                        .presentationDetents([.height(400)])
                }
            }
            .background(Image(backImage).resizable().frame(width: 600,height: 800).offset(y:-100))
        }
    }
    
    func fetchWeatherIfNeeded() async {
        if changeWeather {
            while !location.safeCheck() {
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // Sleep for 0.1 seconds
                } catch {
                    // Handle the error, if needed
                    print("Task sleep error: \(error)")
                }
            }
            do {
                await location.fetchWeather()
                switch location.weather {
                case "Rain":
                    weather = "rain"
                    backImage = "cloudy"
                case "Clouds":
                    weather = "cloudy"
                    backImage = "cloudyBright"
                case "Clear":
                    weather = "clear"
                default:
                    break
                }
                changeWeather.toggle()
            }
        }
    }


    
    @ViewBuilder
    func HeaderView() -> some View{
        VStack(alignment: .leading, spacing: 6) {
            ZStack{
                if weather == "clear" {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.opacity(0.7))
                        .frame(width: 235, height: 70).blur(radius: 30)
                }
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.7))
                    .frame(width: 235, height: 70)
                VStack(alignment: .leading) {
                    HStack(spacing: 5) {
                        Text(currentDate.format("MMMM"))
                            .foregroundStyle(.blue)
                        
                        Text(currentDate.format("YYYY"))
                            .foregroundStyle(Color(UIColor(named: "darkGray")!))
                    }
                    .font(.title.bold())
                    .frame(alignment: .leading)
                    
                    Text(currentDate.formatted(date: .complete, time: .omitted))
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(UIColor(named: "darkGray")!))
                }
                .frame(width: 230, height: 70, alignment: .leading)
                .offset(x:7)
            }
            .offset(x:1)
            .overlay {
                if weather == "rain" {
                    GeometryReader{_ in
                        SpriteView(scene: RainFallLanding(),options: [.allowsTransparency])
                    }.offset(y:-25)
                }
            }
            ZStack{
                if weather == "clear"{
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.opacity(0.7))
                        .frame(width: 400,height: 90).blur(radius: 30)
                }
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.7))
                    .frame(width: 400,height: 90)
                
                TabView(selection: $currentWeekIndex) {
                    ForEach(weekSlider.indices, id: \.self){index in
                        let week = weekSlider[index]
                        WeekView(week)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 90)
            }
            .overlay {
                if weather == "rain" {
                    GeometryReader{_ in
                        SpriteView(scene: RainFallLanding(),options: [.allowsTransparency])
                    }.offset(x:105,y:-60).frame(width: 150,height: 20)
                }
            }
        }
        .padding(15)
        .hSpacing(.leading)
        .onChange(of: currentWeekIndex) { newValue in
            if newValue == 0 || newValue == (weekSlider.count - 1) {
                createWeek = true
            }
        }
    }
    @ViewBuilder
    func WeekView(_ week: [Date.WeekDay]) -> some View {
        HStack(spacing: 0) {
            ForEach(week) { day in
                VStack(spacing: 8) {
                    Text(day.date.format("E"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(UIColor(named: "darkGray")!))
                    
                    Text(day.date.format("dd"))
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundStyle(isSameDate(day.date, currentDate) ? .white: Color(UIColor(named: "darkGray")!))
                        .frame(width: 35, height: 35)
                        .background() {
                            if isSameDate(day.date, currentDate) {
                                Circle()
                                    .fill(.blue)
                                  .matchedGeometryEffect(id: "TABINDICATOR", in: animation)
                            }
                            
                            if day.date.isToday {
                                Circle()
                                    .fill(.cyan)
                                    .frame(width: 6, height: 6)
                                    .vSpacing(.bottom)
                                    .offset(y: 10)
                            }
                        }
                        .background(.white.shadow(.drop(radius: 1)), in: Circle())
                }
                .hSpacing(.center)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation() {
                        currentDate = day.date
                    }
                }
            }
        }
        .background{
            GeometryReader {
                let minX = $0.frame(in: .global).minX
                
                Color.clear
                    .preference(key: OffsetKey.self, value: minX)
                    .onPreferenceChange(OffsetKey.self) { value in
                        if (10..<20).contains(value) && createWeek {
                            paginateWeek()
                            createWeek = false
                        }
                    }
            }
        }
    }
    
    func paginateWeek(){
        if weekSlider.indices.contains(currentWeekIndex){
            if let first = weekSlider[currentWeekIndex].first?.date, currentWeekIndex == 0 {
//                print("a")
                weekSlider.insert(first.createPrevWeek(), at: 0)
                weekSlider.removeLast()
                currentWeekIndex = 1
            }
            
            if let last = weekSlider[currentWeekIndex].last?.date, currentWeekIndex == (weekSlider.count-1){
//                print("a")
                weekSlider.append(last.createNextWeek())
                weekSlider.removeFirst()
                currentWeekIndex = weekSlider.count - 2
            }
        }
    }
}

struct NewTaskView_Previews: PreviewProvider {
    static var previews: some View {
        NewTaskView(userId: "ZQhOQS6ofvfq7rY0SnX1dhFn9qx1")
    }
}

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

