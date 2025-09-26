//
//  ModelStatusIndicator.swift
//  summary
//
//  Created by Assistant on 23/09/2025.
//

import SwiftUI

struct ModelStatusIndicator: View {
    @ObservedObject var statusService: ModelStatusService
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Indicateur compact
            HStack {
                statusIcon
                
                Text(statusService.allModelsReady ? "Modèles prêts" : "Initialisation...")
                    .font(.caption)
                    .foregroundColor(statusService.allModelsReady ? .green : .orange)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
            )
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }
            
            // Vue détaillée (expandable)
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    modelStatusRow(
                        title: "Gemma 3n",
                        status: statusService.gemmaStatus,
                        progress: statusService.gemmaDownloadProgress
                    )
                    
                    modelStatusRow(
                        title: "WhisperKit",
                        status: statusService.whisperKitStatus,
                        progress: nil
                    )
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }
    
    private var statusIcon: some View {
        Group {
            if statusService.allModelsReady {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
    }
    
    private func modelStatusRow(title: String, status: ModelStatus, progress: Double?) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            Spacer()
            
            HStack(spacing: 4) {
                statusIconFor(status)
                statusTextFor(status, progress: progress)
            }
        }
    }
    
    private func statusIconFor(_ status: ModelStatus) -> some View {
        Group {
            switch status {
            case .loaded:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .loading, .downloading:
                ProgressView()
                    .scaleEffect(0.6)
            case .error:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            case .notLoaded:
                Image(systemName: "circle")
                    .foregroundColor(.gray)
            }
        }
        .font(.caption)
    }
    
    private func statusTextFor(_ status: ModelStatus, progress: Double?) -> some View {
        Group {
            switch status {
            case .loaded:
                Text("Prêt")
                    .foregroundColor(.green)
            case .loading:
                Text("Chargement...")
                    .foregroundColor(.orange)
            case .downloading:
                if let progress = progress {
                    Text("\(Int(progress * 100))%")
                        .foregroundColor(.blue)
                } else {
                    Text("Téléchargement...")
                        .foregroundColor(.blue)
                }
            case .error(let message):
                Text("Erreur")
                    .foregroundColor(.red)
            case .notLoaded:
                Text("Non chargé")
                    .foregroundColor(.gray)
            }
        }
        .font(.caption2)
    }
}

#Preview {
    VStack(spacing: 20) {
        ModelStatusIndicator(statusService: {
            let service = ModelStatusService()
            service.gemmaStatus = .loading
            service.whisperKitStatus = .loaded
            return service
        }())
        
        ModelStatusIndicator(statusService: {
            let service = ModelStatusService()
            service.gemmaStatus = .downloading
            service.whisperKitStatus = .loading
            service.gemmaDownloadProgress = 0.65
            return service
        }())
        
        ModelStatusIndicator(statusService: {
            let service = ModelStatusService()
            service.gemmaStatus = .loaded
            service.whisperKitStatus = .loaded
            return service
        }())
    }
    .padding()
}