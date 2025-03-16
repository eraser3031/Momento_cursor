import SwiftUI

struct WisdomDetailView: View {
    @EnvironmentObject var wisdomStore: WisdomStore
    @Environment(\.presentationMode) var presentationMode
    
    let wisdom: Wisdom
    @State private var editedWisdom: Wisdom
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    
    init(wisdom: Wisdom) {
        self.wisdom = wisdom
        _editedWisdom = State(initialValue: wisdom)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 내용
                contentSection
                
                Divider()
                
                // 메타데이터
                metadataSection
                
                // 컨텍스트
                if let context = wisdom.context, !context.isEmpty {
                    contextSection(context)
                }
                
                // 미디어
                if let mediaURL = wisdom.mediaURL {
                    mediaSection(mediaURL)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("지혜 상세")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        wisdomStore.toggleFavorite(wisdom)
                    }) {
                        Image(systemName: wisdom.isFavorite ? "star.fill" : "star")
                            .foregroundColor(wisdom.isFavorite ? .yellow : .gray)
                    }
                    
                    Menu {
                        Button(action: {
                            isEditing = true
                        }) {
                            Label("편집", systemImage: "pencil")
                        }
                        
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            Label("삭제", systemImage: "trash")
                        }
                        
                        Button(action: {
                            shareWisdom()
                        }) {
                            Label("공유", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditWisdomView(wisdom: $editedWisdom, isPresented: $isEditing)
                .onDisappear {
                    if isEditing == false {
                        wisdomStore.updateWisdom(editedWisdom)
                    }
                }
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("지혜 삭제"),
                message: Text("이 지혜를 정말 삭제하시겠습니까?"),
                primaryButton: .destructive(Text("삭제")) {
                    wisdomStore.deleteWisdom(id: wisdom.id)
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel(Text("취소"))
            )
        }
    }
    
    // 내용 섹션
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(wisdom.content)
                .font(.title3)
                .fontWeight(.medium)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
        }
    }
    
    // 메타데이터 섹션
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("출처:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(wisdom.source.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }
            
            HStack {
                Text("카테고리:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(wisdom.category.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
            }
            
            HStack {
                Text("생성일:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(formattedDate(wisdom.createdAt))
                    .font(.subheadline)
            }
            
            if wisdom.updatedAt != wisdom.createdAt {
                HStack {
                    Text("수정일:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(formattedDate(wisdom.updatedAt))
                        .font(.subheadline)
                }
            }
        }
    }
    
    // 컨텍스트 섹션
    private func contextSection(_ context: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("컨텍스트")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(context)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    // 미디어 섹션
    private func mediaSection(_ url: URL) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("관련 미디어")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(url.absoluteString)
                .font(.caption)
                .foregroundColor(.blue)
        }
    }
    
    // 날짜 포맷팅
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // 지혜 공유
    private func shareWisdom() {
        let text = wisdom.content
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
}

#Preview {
    NavigationView {
        WisdomDetailView(wisdom: WisdomStore().wisdoms[0])
            .environmentObject(WisdomStore())
    }
} 
