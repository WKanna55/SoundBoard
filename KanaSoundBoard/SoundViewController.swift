//
//  SoundViewController.swift
//  KanaSoundBoard
//
//  Created by Willian Kana Choquenaira on 9/10/24.
//

import UIKit
import AVFoundation
import CoreData

class SoundViewController: UIViewController {
    
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    
    var grabarAudio: AVAudioRecorder?
    var reproducirAudio: AVAudioPlayer?
    var audioURL: URL?
    // tarea visualizar tiempo
    @IBOutlet weak var lblContadorSegundos: UILabel!
    var timer: Timer?
    var elapsedTimeInSeconds = 0
    var audioDuracion: String = "00:00"
    
    //tarea cambiar volumen
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var lblVolumen: UILabel!
    var volumenFinal: Float = 0.5
    
    @IBAction func volumeChanged(_ sender: UISlider) {
        let value = sender.value
        reproducirAudio?.volume = value
        updateVolumeLabel(value: value)
        volumenFinal = value
    }
    
    
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            grabarAudio?.stop()
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
            // Detener el timer
            timer?.invalidate()
            timer = nil
            //elapsedTimeInSeconds = 0
            updateTimerLabel()
            audioDuracion = lblContadorSegundos.text!
        } else {
            grabarAudio?.record()
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
            // Iniciar el timer
            elapsedTimeInSeconds = 0
            updateTimerLabel()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            
        }
    }
    @IBAction func reproducirTapped(_ sender: Any) {
        
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio?.volume = volumenFinal
            reproducirAudio!.play()
            print("Reproduciendo")
        } catch {}
    }
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.duracion = audioDuracion
        grabacion.volumen = volumenFinal
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController?.popViewController(animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
    }
    
    func configurarGrabacion(){
        do{
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            print("**************************")
            print(audioURL!)
            print("**************************")
            
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        } catch let error as NSError {
            print(error)
        }
    }
    
    // Tarea visualizar duracion en segundos
    // Función que se ejecuta cada segundo para actualizar el timer
    @objc func updateTimer() {
        elapsedTimeInSeconds += 1
        updateTimerLabel()
    }
    // Función para actualizar el texto del label
    func updateTimerLabel() {
        let minutes = elapsedTimeInSeconds / 60
        let seconds = elapsedTimeInSeconds % 60
        lblContadorSegundos.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    // tarea volumen modificar
    func setupVolumeControl() {
        // Configurar el slider
        volumeSlider.minimumValue = 0.0
        volumeSlider.maximumValue = 1.0
        volumeSlider.value = 0.5 // Valor inicial
    
        // Agregar imágenes para los extremos (opcional)
        volumeSlider.minimumValueImage = UIImage(systemName: "speaker.fill")
        volumeSlider.maximumValueImage = UIImage(systemName: "speaker.wave.3.fill")
            
        // Configurar el color del slider
        volumeSlider.tintColor = .systemBlue
            
        // Actualizar el label inicial
        updateVolumeLabel(value: volumeSlider.value)
    }
    
    func updateVolumeLabel(value: Float) {
        // Convertir el valor a porcentaje
        let percentage = Int(value * 100)
        lblVolumen.text = "\(percentage) %"
    }
    
}
