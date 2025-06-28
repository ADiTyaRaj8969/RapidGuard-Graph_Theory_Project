from kivy.lang import Builder
from kivymd.app import MDApp
from kivy.uix.screenmanager import ScreenManager, Screen
from twilio.rest import Client
import pandas as pd
import networkx as nx
import matplotlib.pyplot as plt

KV = '''
ScreenManager:
    MainScreen:
    AddIncidentScreen:

<MainScreen>:
    name: 'main'
    BoxLayout:
        orientation: 'vertical'
        padding: 20
        spacing: 20
        
        MDRaisedButton:
            text: "Run Incident Report"
            on_press: root.run_report()
            size_hint_y: None
            height: "48dp"
        
        MDRaisedButton:
            text: "Add Incident"
            on_press: root.manager.current = 'add'
            size_hint_y: None
            height: "48dp"
        
        ScrollView:
            MDLabel:
                id: output_label
                text: "Output will be displayed here"
                halign: "left"
                size_hint_y: None
                height: self.texture_size[1]

<AddIncidentScreen>:
    name: 'add'
    BoxLayout:
        orientation: 'vertical'
        padding: 20
        spacing: 20

        MDTextField:
            id: incident_location
            hint_text: "Enter Incident Location"
            mode: "rectangle"

        MDTextField:
            id: nearest_centre
            hint_text: "Enter Nearest Centre"
            mode: "rectangle"
        
        MDRaisedButton:
            text: "Save Incident"
            on_press: root.save_incident()
        
        MDRaisedButton:
            text: "Back"
            on_press: root.manager.current = 'main'
'''

class MainScreen(Screen):
    def run_report(self):
        try:
            # Twilio credentials
            account_sid = 'AC263d2cb151d151dddd1766eac4e88106'
            auth_token = 'ec43e2a2060a6d8cd990cc6418e4add7'
            client = Client(account_sid, auth_token)

            # Read CSV files
            member_list = pd.read_csv('Book1.csv')  # Update path
            incident_report = pd.read_csv('Book2.csv')  # Update path

            # Create graph
            G = nx.Graph()
            output_text = ""

            for _, incident in incident_report.iterrows():
                loc = incident['incident_location']
                centre = incident['nearest_centre']
                
                # Find nearest members
                nearest_members = member_list[member_list['centre'] == centre]
                
                output_text += f"Incident at {loc} (Centre: {centre}):\n"
                
                if not nearest_members.empty:
                    for _, member in nearest_members.iterrows():
                        # Send SMS
                        try:
                            message = client.messages.create(
                                body=f"Incident at {loc} (Centre: {centre})",
                                from_='+14423009043',
                                to=member['phone_number']
                            )
                            output_text += f"SMS sent to {member['member_name']}\n"
                        except Exception as e:
                            output_text += f"Failed to send SMS: {str(e)}\n"
                else:
                    output_text += "No members found for this centre\n"
                
                output_text += "\n"

            self.ids.output_label.text = output_text

        except Exception as e:
            self.ids.output_label.text = f"Error: {str(e)}"

class AddIncidentScreen(Screen):
    def save_incident(self):
        try:
            location = self.ids.incident_location.text
            centre = self.ids.nearest_centre.text
            
            if location and centre:
                df = pd.DataFrame({
                    'incident_location': [location],
                    'nearest_centre': [centre]
                })
                df.to_csv('Book2.csv', mode='a', header=False, index= False)
                self.ids.incident_location.text = ''
                self.ids.nearest_centre.text = ''
                self.manager.current = 'main'
            else:
                print("Please fill in both fields")
        except Exception as e:
            print(f"Error saving incident: {str(e)}")

class IncidentApp(MDApp):
    def build(self):
        self.screen_manager = ScreenManager()
        Builder.load_string(KV)
        self.screen_manager.add_widget(MainScreen(name='main'))
        self.screen_manager.add_widget(AddIncidentScreen(name='add'))
        return self.screen_manager

if __name__ == '__main__':
    IncidentApp().run()